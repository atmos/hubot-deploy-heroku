Path         = require "path"
ScopedClient = require "scoped-http-client"

Helpers                = require Path.join __dirname, "helpers"
Octonode               = require "octonode"
Deployment             = Helpers.Deployment
GitHubDeploymentStatus = require("hubot-deploy/src/models/github_requests").GitHubDeploymentStatus

class Deployment
  constructor: (@deployment, @herokuToken, @githubToken, @logger) ->
    @description = @deployment.payload.deployment.description.match(/from hubot-deploy/)
    @number      = @deployment.payload.deployment.id
    @yubikey     = @deployment.yubikey
    @repoName    = @deployment.payload.repository.full_name
    @appName     = @appName()
    @version     = @deployment.payload.deployment.sha[0..8]

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
        header("Authorization", "Bearer #{@herokuToken}").
        header("Heroku-Two-Factor-Code", "#{@yubikey}")
    else
      ScopedClient.create("https://api.heroku.com").
        header("Accept", "application/vnd.heroku+json; version=3").
        header("Content-Type", "application/json").
        header("Authorization", "Bearer #{@herokuToken}")

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

  archiveUrl: (callback) ->
    octonode = Octonode.client(@githubToken)
    octonode.repo(@repoName).archive "tarball", @version, (err, archiveUrl, headers) =>
      if err
        @log "Error getting tarball: #{err}"
      callback(err, archiveUrl, headers)

  build: (callback) ->
    @archiveUrl (err, archiveUrl, headers) =>
      @log err if err
      data = JSON.stringify(source_blob: { url: archiveUrl, version: @version })

      @log "Build Payload: #{data}"
      @httpRequest().path("/apps/#{@appName}/builds").
        post(data) (err, res, body) =>
          callback(err, res, body, null)

  postBuild: (err, res, body, callback) ->
    data        = JSON.parse(body)
    deployment  = @deployment.payload.deployment

    ref      = deployment.ref
    repoName = deployment.repoName

    if err
      callback(new Error(err.toString()), res, body, null)

    else if res?.statusCode is 201
      buildId   = data.id
      outputUrl = data.output_stream_url

      info   = new Helpers.BuildInfo @herokuToken, @appName, buildId
      status = new GitHubDeploymentStatus @githubToken, @repoName, @number
      status.targetUrl = "https://dashboard.heroku.com/apps/#{@appName}/activity/builds/#{buildId}"

      reaper = new Helpers.Reaper(info, status, @logger)
      reaper.watch (err, res, body, reaper) ->
        callback(err, res, body, reaper)
    else
      @log JSON.stringify(res.statusCode) if res?
      @log JSON.stringify(body) if body?
      callback(null, res, body, null)

  run: (callback) ->
    unless @deployment.notify? and @description and @appName
      callback(null, null, null, null)

    @log "Found heroku chat deployed request for #{@appName}"
    @preAuthorize (err, res, body) =>
      @log err if err

      @build (err, res, body) =>
        @postBuild err, res, body, (err, res, body, reaper) ->
          callback(err, res, body, reaper)

exports.Deployment = Deployment
