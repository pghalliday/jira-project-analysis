request = require 'request'
JSONStream = require 'JSONStream'
reduce = require 'stream-reduce'
Q = require 'q'
_ = require 'underscore'

queryPromise = (query, filter, initialValue, accumulator) ->
  deferred = Q.defer()
  jsonStream = JSONStream.parse filter
  reduceStream = reduce accumulator, initialValue
  reduceStream.on 'data', (value) ->
    deferred.resolve value
  query.pipe(jsonStream).pipe(reduceStream)
  deferred.promise

totalPromise = (query) ->
  queryPromise query, 'total', 0, (total, newTotal) ->
    total = newTotal
    total

# params =
#   serverRoot: 'https://jira.myserver.com'
#   strictSSL: true
#   user: 'username'
#   pass: 'password'
#   jql: 'project = "myproject"'
#   fields: '*all'
#   maxResults: 50
#   issueAccumulator: (issues, issue) ->
#     issues.push issue.key
#     issues

module.exports = (params) ->
  queryParams = (startAt) ->
    method: 'GET'
    strictSSL: params.strictSSL
    auth:
      user: params.user
      pass: params.pass
      sendImmediately: true
    uri: params.serverRoot + '/rest/api/2/search'
    qs:
      jql: params.jql
      maxResults: params.maxResults
      startAt: startAt
      fields: params.fields
  issuesPromise = (query) ->
    queryPromise query, 'issues.*', [], params.issueAccumulator
  Q()
    .then ->
      query = request queryParams 0
      [
        totalPromise query
        issuesPromise query
      ]
    .spread (total, issues) ->
      remaining = total - params.maxResults
      remainingPromise = ->
        query = request queryParams total - remaining
        remaining -= params.maxResults
        issuesPromise query
      Q.all [].concat(issues, remainingPromise() while remaining > 0)
    .then (issuesArray) ->
      _.flatten issuesArray, true
