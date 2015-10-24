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
    ScopedClient.create("https://api.heroku.com").
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

class Reaper
  constructor: (@info, @status, @logger) ->
    @sleepFor = 10

  log: (string) ->
    if @logger?
      @logger.info string

  watch: () ->
    log  =   @log
    info =   @info
    status = @status
    maxTries = 18

    pollForCompletion = ( ) ->
      maxTries -= 1
      log "Polling Heroku Build: #{info.appName}:#{info.id}"
      info.status (err, res, body) =>
        try
          if err
            log "Error polling in heroku: #{err}"

          data = JSON.parse(body)
          if maxTries > 0 and data['status'] is "pending"
            setTimeout(pollForCompletion, 10000)
          else
            switch data["status"]
              when "succeeded"
                status.state = "success"
              else
                status.state = "failure"
            status.create (err, res, body) ->
              log "Polling Heroku Build: #{info.appName}:#{info.id}:#{status.state}"
        catch err
          log "Error in pollForCompletion on heroku: #{err}"

    info.status (err, res, body) =>
      status.state = "pending"
      status.create (err, res, body) =>
        setTimeout pollForCompletion

exports.Reaper        = Reaper
exports.BuildInfo     = BuildInfo
exports.TokenVerifier = TokenVerifier
exports.Deployment    = require("./src/deployment").Deployment
###########################################################################
