q = require 'q'
fs = require 'q-io/fs'
path = require 'path'
moment = require 'moment'
stringify = require 'csv-stringify'
JiraApi = require('jira').JiraApi

config =
  protocol: 'https'
  host: 'jira.upc.biz'
  port: 443
  username: process.env.JIRA_USER
  password: process.env.JIRA_PASSWORD
  apiVersion: '2'
  verbose: false
  strictSSL: false
  oauth: false

jira = new JiraApi(
  config.protocol
  config.host
  config.port
  config.username
  config.password
  config.apiVersion
  config.verbose
  config.strictSSL
  config.oauth
)

days = 60
now = moment()
seriesList = [
    name: 'helios-application-framework open and assigned'
    jql:
      'project="Helios" and ' +
      'component="helios-application-framework" and ' +
      'status was in ("To Do", "In Progress") on "__DATE__" and ' +
      'assignee was in (brendan.meade, acampo, rnieuwboer, ajunqueira, alarocca) on "__DATE__"'
  ,
    name: 'helios-application-framework open'
    jql:
      'project="Helios" and ' +
      'component="helios-application-framework" and ' +
      'status was in ("To Do", "In Progress") on "__DATE__"'
]

series = (name, jql) ->
  query = (day) ->
    date = moment(now).subtract(day, 'days').format 'YYYY/MM/DD'
    jqlWithDate = jql.replace /__DATE__/g, date
    q()
      .then ->
        q.ninvoke jira, 'searchJira', jqlWithDate,
          maxResults: 1
      .then (result) ->
        date: date
        count: result.total
  queries = (query day for day in [(days-1)..0])
  q()
    .then ->
      q.all queries
    .then (data) ->
      q.nfcall stringify, data,
        header: true
        columns:
          date: 'date'
          count: 'count'
    .then (csv) ->
      file = path.join __dirname, name + '.csv'
      console.log 'Writing file: ' + file
      fs.write file, csv
      
q()
  .then ->
    q.all (series(seriesListItem.name, seriesListItem.jql) for seriesListItem in seriesList)
  .done()
