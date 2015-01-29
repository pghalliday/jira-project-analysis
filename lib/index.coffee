Q = require 'q'
fs = require 'q-io/fs'
fscore = require 'fs'
path = require 'path'
stringify = require 'csv-stringify'
Progress = require 'progress'
_ = require 'underscore'
search = require './search'
State = require './State'

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
        jql += (' and issuetype not in (' + _.reduce(types, ((types, type) -> types + (if types.length then ', ' else '') + '"' + type  + '"'), '')  + ')') if types.length
      statuses = exclude.statuses
      if statuses
        jql += (' and status not in (' + _.reduce(statuses, ((statuses, status) -> statuses + (if statuses.length then ', ' else '') + '"' + status  + '"'), '')  + ')') if statuses.length
    bar = undefined
    [path.resolve(outputDir, config.output.days), path.resolve(outputDir, config.output.issues)].concat(
      search
        serverRoot: jira.protocol + '://' + jira.host
        strictSSL: jira.strictSSL
        user: jira.username
        pass: jira.password
        jql: jql
        fields: 'issuetype,created,resolutiondate,priority,resolution,status,labels,components'
        expand: 'changelog'
        maxResults: 50
        onTotal: (total) ->
          bar = new Progress '  querying :current/:total :elapseds [:bar] :percent :etas',
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
    )
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
