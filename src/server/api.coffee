apps = require 'q-io/http-apps'

module.exports = (client) ->
  (request) ->
    apps.ok 'Hello, world!'
