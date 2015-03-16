Q = require 'q'
fs = require 'q-io/fs'
fscore = require 'fs'
path = require 'path'
stringify = require 'csv-stringify'
Progress = require 'progress'
_ = require 'underscore'
moment = require 'moment'
search = require './search'
issueClass = require './Issue'

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
  'parent'
  'summary'
  'description'
  'comment'
].join ','

progressBarFormat = (action) ->
  '  ' + action + ' :current/:total :elapseds [:bar] :percent :etas'

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
    Issue = issueClass(
      config.statusMap
    )
    [
      Issue
      path.resolve(outputDir, config.output)
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
          bar = new Progress progressBarFormat('querying'),
            total: total
            complete: '='
            incomplete: ' '
            width: 20
          bar.tick 0
        mapCallback: (issue) ->
          bar.tick()
          new Issue issue
    ]
  .spread (Issue, output, issues) ->
    if Issue.unknownStatuses.length
      console.log 'WARNING: Unknown statuses'
      console.log JSON.stringify Issue.unknownStatuses, null, '  '
    [output].concat [
      Q.nfcall stringify, issues,
        header: true
        columns: Issue.columns
    ]
  .spread (output, csv) ->
    [output].concat [
      fs.write output, csv
    ]
  .spread (output) ->
    console.log '\n  CSV data written to:'
    console.log '\n    ' + output + '\n'
  .done()
