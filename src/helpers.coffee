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
    @token = token?.trim()

  valid: (cb) ->
    ScopedClient.create("https://api.heroku.com").
      header("Accept", "application/vnd.heroku+json; version=3").
      header("Authorization", "Bearer #{@token}").
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
    @maxTries = 45
    @sleepFor = 10

  log: (string) ->
    if @logger?
      @logger.info string

  watch: (callback) ->
    log  =   @log
    self =   @
    info =   @info
    status = @status
    maxTries = @maxTries

    pollForCompletion = ( ) ->
      maxTries -= 1
      log "Polling Heroku Build: #{info.appName}:#{info.id}"
      info.status (err, res, body) =>
        try
          if err
            log "Error polling in heroku: #{err}"
            return callback(err, res, body, self)

          data = JSON.parse(body)
          if maxTries > 0 and data['status'] is "pending"
            setTimeout(pollForCompletion, process.env.REAPER_TIMEOUT || 10000)
          else
            switch data["status"]
              when "succeeded"
                status.state = "success"
              else
                status.state = "failure"

            if maxTries is 0
              status.description = "Build took too long to complete."
            status.create (err, res, body) ->
              callback(err, res, body, self)
          log "Polling Heroku Build: #{info.appName}:#{info.id}:#{status.state}"
        catch err
          log "Error in pollForCompletion on heroku: #{err}"

    info.status (err, res, body) =>
      status.state = "pending"
      status.create (err, res, body) =>
        setTimeout pollForCompletion, 0

exports.Reaper        = Reaper
exports.BuildInfo     = BuildInfo
exports.TokenKey      = "hubot-deploy-heroku-secret"
exports.TokenVerifier = TokenVerifier
exports.Deployment    = require("./deployment").Deployment
###########################################################################
