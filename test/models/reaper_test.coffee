Log  = require "log"
Path = require "path"

pkg = require Path.join __dirname, "..", "..", "package.json"
pkgVersion = pkg.version

VCR = require "vcr"

HerokuHelpers = require Path.join __dirname, "..", "..", "src", "helpers"
GitHubDeploymentStatus = require("hubot-deploy/src/models/github_requests").GitHubDeploymentStatus

Reaper = HerokuHelpers.Reaper

describe "The Reaper", () ->
  info    = undefined
  status  = undefined
  appName = "hubot"
  buildId = "01234567-89ab-cdef-0123-456789abcdef"

  logger = new Log process.env.HUBOT_LOG_LEVEL or 'info'
  beforeEach () ->
    VCR.playback()
    info = new HerokuHelpers.BuildInfo "token", "hubot", buildId
    status = new GitHubDeploymentStatus "github_token", "atmos/my-robot", 1875476
    status.targetUrl = "https://dashboard.heroku.com/apps/#{appName}/activity/builds/#{buildId}"
  afterEach () ->
    VCR.stop()

  it "properly flags repos when a build is succeeded", (done) ->
    VCR.play "/apps-hubot-builds-#{buildId}-succeeded", 2
    VCR.play "/repos-atmos-my-robot-deployments-1875476-statuses-success", 2

    reaper = new HerokuHelpers.Reaper(info, status, logger)
    reaper.watch (err, res, body, reaper) ->
      throw err if err
      responseBody = JSON.parse(body)
      assert.equal "success", reaper.status.state
      assert.equal "Deployment finished successfully.", responseBody.description
      assert.equal "https://example.com/deployment/1875476/output", responseBody.target_url
      done()

  it "properly flags repos when a build failed", (done) ->
    VCR.play "/apps-hubot-builds-#{buildId}-failed", 2
    VCR.play "/repos-atmos-my-robot-deployments-1875476-statuses-failure", 2

    reaper = new HerokuHelpers.Reaper(info, status, logger)
    reaper.watch (err, res, body, reaper) ->
      throw err if err
      responseBody = JSON.parse(body)
      assert.equal "failure", reaper.status.state
      assert.equal "Deployment failed to complete.", responseBody.description
      assert.equal "https://example.com/deployment/1875476/output", responseBody.target_url
      done()

  it "properly flags repos when a build times out", (done) ->
    VCR.play "/apps-hubot-builds-#{buildId}-pending", 5
    VCR.play "/repos-atmos-my-robot-deployments-1875476-statuses-pending", 3

    reaper = new HerokuHelpers.Reaper(info, status, logger)
    reaper.maxTries = 2
    reaper.watch (err, res, body, reaper) ->
      throw err if err
      responseBody = JSON.parse(body)
      assert.equal "failure", reaper.status.state
      assert.equal "Deployment running.", responseBody.description
      assert.equal "https://example.com/deployment/1875476/output", responseBody.target_url
      done()
