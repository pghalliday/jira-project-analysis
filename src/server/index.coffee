q = require 'q'
http = require 'q-io/http'
apps = require 'q-io/http-apps'
path = require 'path'
redis = require 'redis'
api = require './api'

root = path.resolve path.join __dirname, '../client'
port = 5000

q()
  .then ->
    deferred = q.defer()
    client = redis.createClient 6379, 'redis'
    client.on 'ready', ->
      deferred.resolve client
    deferred.promise
  .then (client) ->
    defaultRoute = apps.FileTree root
    branchRoutes =
      'api': api client
    server = http.Server apps.Branch branchRoutes, defaultRoute
    server.listen port
  .done()
