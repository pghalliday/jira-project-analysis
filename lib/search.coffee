request = require 'request'
JSONStream = require 'JSONStream'
reduce = require 'stream-reduce'
Q = require 'q'
_ = require 'underscore'

# params =
#   serverRoot: 'https://jira.myserver.com'
#   strictSSL: true
#   user: 'username'
#   pass: 'password'
#   jql: 'project = "myproject"'
#   fields: '*all'
#   maxResults: 50
#   onTotal: (total) ->
#     bar = new Progress '  querying :elapseds [:bar] :percent :etas',
#       total: total
#       complete: '='
#       incomplete: ' '
#       width: 20
#     bar.tick 0
#   issueAccumulator: (issues, issue) ->
#     bar.tick()
#     issues.push issue.key
#     issues

module.exports = (params) ->
  queryParams = (startAt, maxResults) ->
    method: 'GET'
    strictSSL: params.strictSSL
    auth:
      user: params.user
      pass: params.pass
      sendImmediately: true
    uri: params.serverRoot + '/rest/api/2/search'
    qs:
      jql: params.jql
      maxResults: maxResults
      startAt: startAt
      fields: params.fields
  issuesPromise = (query) ->
    queryPromise query, 'issues.*', [], params.issueAccumulator
  Q()
    .then ->
      query = request queryParams 0, 0
      deferred = Q.defer()
      jsonStream = JSONStream.parse 'total'
      jsonStream.once 'data', (value) ->
        deferred.resolve value
      query.pipe jsonStream
      deferred.promise
    .then (total) ->
      params.onTotal total
      remaining = total
      issuesPromise = ->
        deferred = Q.defer()
        jsonStream = JSONStream.parse 'issues.*'
        reduceStream = reduce params.issueAccumulator, []
        reduceStream.on 'data', (issues) ->
          deferred.resolve issues
        query = request queryParams total - remaining, params.maxResults
        remaining -= params.maxResults
        query.pipe(jsonStream).pipe(reduceStream)
        deferred.promise
      Q.all (issuesPromise() while remaining > 0)
    .then (issuesArray) ->
      _.flatten issuesArray, true
