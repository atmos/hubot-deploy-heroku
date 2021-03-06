Fs  = require "fs"
Log = require "log"

VCR  = require "ys-vcr"
Path = require "path"
Package = require Path.join __dirname, "..", "..", "package.json"
Version = Package.version

HubotDeployGitHubDeployment = require("hubot-deploy/src/models/github_events").Deployment

HubotDeployHeroku = require Path.join __dirname, "..", "..", "src", "helpers"
Deployment        = HubotDeployHeroku.Deployment

fixtureDir = Path.join(__dirname, "..", "support", "github", "deployments")

describe "Deploying to heroku", () ->
  logger     = undefined # new Log process.env.HUBOT_LOG_LEVEL or 'info'
  buildId    = "01234567-89ab-cdef-0123-456789abcdef"
  staging    = undefined
  production = undefined

  deploymentData =
    staging:    JSON.parse(Fs.readFileSync("#{fixtureDir}/staging.json"))
    production: JSON.parse(Fs.readFileSync("#{fixtureDir}/production.json"))

  beforeEach () ->
    VCR.playback()
    staging    = new HubotDeployGitHubDeployment(buildId, deploymentData.staging)
    production = new HubotDeployGitHubDeployment(buildId, deploymentData.production)

  afterEach () ->
    VCR.stop()

  it "creates builds", (done) ->
    VCR.play "/repos-atmos-my-robot-archive-3c9f42c76-success"
    VCR.play "/repos-atmos-my-robot-deployments-1875476-statuses-success", 2
    VCR.play "/apps-hubot-builds-#{buildId}-success", 1
    VCR.play "/apps-hubot-builds-#{buildId}-succeeded", 3
    deployment = new Deployment(production, "h-token", "g-token", logger)
    deployment.run (err, res, body) ->
      throw err if err
      parsedBody = JSON.parse(body)
      assert.equal "Deployment finished successfully.", parsedBody.description
      assert.equal "success", parsedBody.state
      done()

  it "fails for unknown reasons", (done) ->
    VCR.play "/repos-atmos-my-robot-archive-3c9f42c76-success"
    VCR.play "/apps-hubot-builds-#{buildId}-failure"
    VCR.play "/apps-hubot-pre-authorizations-failure"
    VCR.play "/repos-atmos-my-robot-deployments-1875476-statuses-failure"
    deployment = new Deployment(production, "h-token", "g-token", logger)
    deployment.yubikey = "ccccccdkhkgtinfvnrrhjveeertdjtdjjilclutikher"
    deployment.run (err, res, body) ->
      throw(err) if err
      assert.equal 401, res.statusCode
      done()


  it "can fail with valid otp", (done) ->
    VCR.play "/repos-atmos-my-robot-archive-3c9f42c76-success"
    VCR.play "/apps-hubot-builds-#{buildId}-failure"
    VCR.play "/apps-hubot-pre-authorizations-success"
    VCR.play "/repos-atmos-my-robot-deployments-1875476-statuses-failure"
    deployment = new Deployment(production, "h-token", "g-token", logger)
    deployment.yubikey = "ccccccdkhkgtinfvnrrhjveeertdjtdjjilclutikher"
    deployment.run (err, res, body) ->
      throw(err) if err
      assert.equal 401, res.statusCode
      done()
