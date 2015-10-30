ScopedClient = require "scoped-http-client"

class Deployment
  constructor: (@deployment, @token, @archiveUrl, @logger) ->
    @description = @deployment.payload.deployment.description.match(/from hubot-deploy/)
    @yubikey     = @deployment.yubikey
    @appName     = @appName()
    @version     = @deployment.payload.deployment.sha

  appName: () ->
    deployment  = @deployment.payload.deployment
    config      = deployment.payload.config
    environment = deployment.environment
    return config["heroku_#{environment}_name"]

  log: (strings) ->
    if @logger?
      @logger.info strings

  httpRequest: () ->
    if @yubikey?
      ScopedClient.create("https://api.heroku.com").
        header("Accept", "application/vnd.heroku+json; version=3").
        header("Content-Type", "application/json").
        header("Authorization", "Bearer #{@token}").
        header("Heroku-Two-Factor-Code", "#{@yubikey}")
    else
      ScopedClient.create("https://api.heroku.com").
        header("Accept", "application/vnd.heroku+json; version=3").
        header("Content-Type", "application/json").
        header("Authorization", "Bearer #{@token}")

  preAuthorize: (callback) ->
    try
      if @yubikey?
        @log "Trying to pre-auth /apps/#{@appName}/pre-authorizations"
        @httpRequest().path("/apps/#{@appName}/pre-authorizations").
          put() (err, res, body) =>
            if err
              callback(err, res, body)
            if res?.statusCode is 401
              @log "Probably a 2FA pre-authorization error, ignoring."
            callback(err, res, body)
      else
        callback(null, null, "Skipped API pre-auth, no yubikey provided.")
    catch err
      @log "Error pre-authorizing: #{err}"

  build: (callback) ->
    data = JSON.stringify(source_blob: { url: @archiveUrl, version: @version })

    @log "Build Payload: #{data}"
    @httpRequest().path("/apps/#{@appName}/builds").
      post(data) (err, res, body) =>
        callback(err, res, body)

  run: (callback) ->
    unless @deployment.notify? and @description and @appName
      callback(null, null, null)

    @log "Found heroku chat deployed request for #{@appName}"
    @preAuthorize (err, res, body) =>
      if err
        @log err

      @build (err, res, body) ->
        callback(err, res, body)

exports.Deployment = Deployment
