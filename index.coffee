Path = require 'path'

ScopedClient = require "scoped-http-client"

class HerokuBuildInfo
  constructor: (@apiToken, @appName, @id) ->

  status: (callback) ->
    ScopedClient.create("https://api.heroku.com").
      header("Accept", "application/vnd.heroku+json; version=3").
      header("Authorization", "Bearer #{@apiToken}").
      path("/apps/#{@appName}/builds/#{@id}").
      get() (err, res, body) ->
        callback(err, res, body)

exports.HerokuBuildInfo = HerokuBuildInfo
