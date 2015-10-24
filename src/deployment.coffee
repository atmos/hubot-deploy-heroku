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
            if res?
              data = JSON.parse(body)
              @log "pre-auth body(#{res.statusCode}): #{body}"
              if res.statusCode is 401
                @log "Probably a 2FA pre-authorization error, ignoring."
            callback(err, res, body)
      else
        callback(null, null, "Skipped API pre-auth, no yubikey provided.")
    catch err
      @log "Error pre-authorizing: #{err}"

  build: (callback) ->
    try
      data = JSON.stringify(source_blob: { url: @archiveUrl, version: @version })

      @log "Build Payload: #{data}"
      @httpRequest().path("/apps/#{@appName}/builds").
        post(data) (err, res, body) =>
          data = JSON.parse(body)
          if res.statusCode is 401
            @log "Build body(#{res.statusCode}): #{body}"
            callback(new Error("#{data.id} - #{data.message}"), null, "Probably a 2FA error")

          callback(err, res, body)
    catch err
      @log "Error creating build: #{err}"

  run: (callback) ->
    try
      unless @deployment.notify? and @description and @appName
        callback(null, null, null)

      @log "Found heroku chat deployed request"
      @preAuthorize (err, res, body) =>
        if err
          @log err

        if res
          @log "Preauth body(#{res.statusCode}): #{body}"
          if res.statusCode isnt 200
            callback(err, res, body)
        else
          @log "Preauth body: #{body}"

        @build (err, res, body) ->
          callback(err, res, body)
    catch err
      @log "Error running deployment: #{err}"

exports.Deployment = Deployment
