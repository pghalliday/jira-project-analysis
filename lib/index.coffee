Q = require 'q'
fs = require 'q-io/fs'
fscore = require 'fs'
path = require 'path'
stringify = require 'csv-stringify'
Progress = require 'progress'
_ = require 'underscore'
search = require './search'
State = require './State'

jqlExcludeValueList = (values) ->
  quotedValues = _.map values, (value) ->
    '"' + value + '"'
  quotedValues.join ', '

jqlExclude = (field, values) ->
  if values.length
    ' and ' + field + ' not in (' +
    jqlExcludeValueList(values) +
    ')'
  else
    ''

jqlFields = [
  'issuetype'
  'created'
  'resolutiondate'
  'priority'
  'resolution'
  'status'
  'labels'
  'components'
].join ','

progressBarFormat = '  querying :current/:total :elapseds [:bar] :percent :etas'

Q()
  .then ->
    configFile = process.argv[2]
    [
      fs.read configFile
      path.dirname fscore.realpathSync configFile
    ]
  .spread (configJSON, outputDir) ->
    config = JSON.parse configJSON
    jira = config.jira
    jql = 'project = "' + config.project + '"'
    exclude = config.exclude
    if exclude
      types = exclude.types
      if types
        jql += jqlExclude 'issuetype', types
      statuses = exclude.statuses
      if statuses
        jql += jqlExclude 'status', statuses
    bar = undefined
    [
      path.resolve(outputDir, config.output.days)
      path.resolve(outputDir, config.output.issues)
      search
        serverRoot: jira.protocol + '://' + jira.host
        strictSSL: jira.strictSSL
        user: jira.username
        pass: jira.password
        jql: jql
        fields: jqlFields
        expand: 'changelog'
        maxResults: 50
        onTotal: (total) ->
          bar = new Progress progressBarFormat,
            total: total
            complete: '='
            incomplete: ' '
            width: 20
          bar.tick 0
        initialState: new State config.days, config.statusMap
        stateAccumulator: (state, issue) ->
          state.addIssue issue
          bar.tick()
          state
    ]
  .spread (outputDays, outputIssues, state) ->
    [outputDays, outputIssues].concat [
      Q.nfcall stringify, state.days,
        header: true
        columns: state.dayColumns
      Q.nfcall stringify, state.issues,
        header: true
        columns: state.issueColumns
    ]
  .spread (outputDays, outputIssues, csvDays, csvIssues) ->
    [outputDays, outputIssues].concat [
      fs.write outputDays, csvDays
      fs.write outputIssues, csvIssues
    ]
  .spread (outputDays, outputIssues) ->
    console.log '\n  CSV data written to:'
    console.log '\n    ' + outputDays
    console.log '\n    ' + outputIssues + '\n'
  .done()
