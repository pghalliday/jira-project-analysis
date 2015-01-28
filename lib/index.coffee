Q = require 'q'
fs = require 'q-io/fs'
fscore = require 'fs'
path = require 'path'
stringify = require 'csv-stringify'
Progress = require 'progress'
_ = require 'underscore'
search = require './search'
State = require './state'

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
    jql = config.jql
    jql = jql.join ' ' if Array.isArray jql
    bar = undefined
    [path.resolve(outputDir, config.output)].concat(
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
        initialState: new State config.days
        stateAccumulator: (state, issue) ->
          state.addIssue issue
          bar.tick()
          state
    )
  .spread (output, state) ->
    [output].concat Q.nfcall stringify, state.days,
      header: true
      columns:
        displayDate: 'date'
        open: 'open'
        openAndAssigned: 'open and assigned'
        leadTime7DayMovingAverage: 'lead time (7 day moving average)'
  .spread (output, csv) ->
    [output].concat fs.write output, csv
  .spread (output) ->
    console.log '\n  CSV data written to ' + output + '\n'
  .done()
