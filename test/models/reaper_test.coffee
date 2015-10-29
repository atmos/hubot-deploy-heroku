Log  = require "log"
Path = require "path"

pkg = require Path.join __dirname, "..", "..", "package.json"
pkgVersion = pkg.version

VCR = require "./../vcr"
Nock = require "nock"

HerokuHelpers = require Path.join __dirname, "..", "..", "src", "helpers"
GitHubDeploymentStatus = require("hubot-deploy/src/models/github_requests").GitHubDeploymentStatus

Reaper = HerokuHelpers.Reaper

describe "The Reaper", () ->
  buildId = "01234567-89ab-cdef-0123-456789abcdef"
  logger = new Log process.env.HUBOT_LOG_LEVEL or 'info'
  beforeEach () ->
    Nock.disableNetConnect()

  it "properly flags repos when a build is succeeded", (done) ->
    VCR.play "/apps-hubot-builds-#{buildId}-succeeded", 2
    VCR.play "/repos-atmos-hubot-deploy-heroku-deployments-42-statuses-success", 2
    appName = "hubot"
    info = new HerokuHelpers.BuildInfo "token", "hubot", buildId
    status = new GitHubDeploymentStatus "github_token", "atmos/hubot-deploy-heroku", 42
    status.targetUrl = "https://dashboard.heroku.com/apps/#{appName}/activity/builds/#{buildId}"

    reaper = new HerokuHelpers.Reaper(info, status, logger)
    reaper.watch (err, res, body, reaper) ->
      responseBody = JSON.parse(body)
      assert.equal "success", reaper.status.state
      assert.equal "Deployment finished successfully.", responseBody.description
      assert.equal "https://example.com/deployment/42/output", responseBody.target_url
      done()

  it "properly flags repos when a build is pending", (done) ->
    VCR.play "/apps-hubot-builds-#{buildId}-pending", 2
    VCR.play "/repos-atmos-hubot-deploy-heroku-deployments-42-statuses-pending", 2

    appName = "hubot"
    info = new HerokuHelpers.BuildInfo "token", "hubot", buildId
    status = new GitHubDeploymentStatus "github_token", "atmos/hubot-deploy-heroku", 42
    status.targetUrl = "https://dashboard.heroku.com/apps/#{appName}/activity/builds/#{buildId}"

    reaper = new HerokuHelpers.Reaper(info, status, logger)
    reaper.watch (err, res, body, reaper) ->
      responseBody = JSON.parse(body)
      assert.equal "pending", reaper.status.state
      assert.equal "Deployment running.", responseBody.description
      assert.equal "https://example.com/deployment/42/output", responseBody.target_url
      done()
