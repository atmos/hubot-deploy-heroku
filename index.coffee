Path = require 'path'

ScopedClient = require "scoped-http-client"

###########################################################################
class BuildInfo
  constructor: (@apiToken, @appName, @id) ->

  status: (callback) ->
    ScopedClient.create("https://api.heroku.com").
      header("Accept", "application/vnd.heroku+json; version=3").
      header("Authorization", "Bearer #{@apiToken}").
      path("/apps/#{@appName}/builds/#{@id}").
      get() (err, res, body) ->
        callback(err, res, body)

class TokenVerifier
  constructor: (token) ->
    @apiToken = token.trim()

  valid: (cb) ->
    ScopedClient.http("https://api.heroku.com").
      header("Accept", "application/vnd.heroku+json; version=3").
      header("Authorization", "Bearer #{@apiToken}").
      path("/account").
      get() (err, res, body) ->
        if err
          cb(false)
        else if res.statusCode isnt 200
          cb(false)
        else
          user = JSON.parse(body)
          cb(user)

exports.BuildInfo     = BuildInfo
exports.TokenVerifier = TokenVerifier

###########################################################################
