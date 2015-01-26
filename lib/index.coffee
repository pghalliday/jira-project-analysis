q = require 'q'
fs = require 'q-io/fs'
fscore = require 'fs'
path = require 'path'
moment = require 'moment'
stringify = require 'csv-stringify'
JiraApi = require('jira').JiraApi
Progress = require 'progress'
_ = require 'underscore'

now = moment()

series = (bar, jira, dates, name, jql) ->
  jql = jql.join ' ' if Array.isArray jql
  query = (date) ->
    jqlWithDate = jql.replace /__DATE__/g, date
    q()
      .then ->
        q.ninvoke jira, 'searchJira', jqlWithDate,
          maxResults: 1
      .then (result) ->
        bar.tick()
        entry = {}
        entry[name] = result.total
        entry
  q()
    .then ->
      q.all (query(date) for date in dates)
      
q()
  .then ->
    configFile = process.argv[2]
    [
      fs.read configFile
      path.dirname fscore.realpathSync configFile
    ]
  .spread (configJSON, outputDir) ->
    config = JSON.parse configJSON
    jira = new JiraApi(
      config.jira.protocol
      config.jira.host
      config.jira.port
      config.jira.username
      config.jira.password
      config.jira.apiVersion
      config.jira.verbose
      config.jira.strictSSL
      config.jira.oauth
    )
    dates = (moment(now).subtract(day, 'days').format('YYYY/MM/DD') for day in [(config.days - 1)..0])
    bar = new Progress '  querying :elapseds [:bar] :percent :etas',
      total: Object.keys(config.queries).length * config.days
      complete: '='
      incomplete: ' '
      width: 20
    bar.tick 0
    [
      {'date': date} for date in dates
      q.all (series(bar, jira, dates, name, jql) for name, jql of config.queries)
      path.resolve outputDir, config.output
    ]
  .spread (dates, data, output) ->
    data.unshift dates
    data = _.zip.apply _, data
    data = (_.extend.apply(_,  entry) for entry in data)
    [
      output
      q.nfcall stringify, data, { header: true }
    ]
  .spread (output, csv) ->
    [
      output
      fs.write output, csv
    ]
  .spread (output) ->
    console.log '\n  CSV data written to ' + output + '\n'
  .done()
