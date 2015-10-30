Fs  = require "fs"
Log = require "log"

VCR  = require "./../vcr"
Path = require "path"
Nock = require "nock"
Package = require Path.join __dirname, "..", "..", "package.json"
Version = Package.version

HubotDeployGitHubDeployment = require("hubot-deploy/src/models/github_events").Deployment

HubotDeployHeroku = require Path.join __dirname, "..", "..", "src", "helpers"
Deployment        = HubotDeployHeroku.Deployment

fixtureDir = Path.join(__dirname, "..", "support", "github", "deployments")

describe "The build information", () ->
  logger     = undefined # new Log process.env.HUBOT_LOG_LEVEL or 'info'
  buildId    = "01234567-89ab-cdef-0123-456789abcdef"
  staging    = undefined
  production = undefined
  archiveUrl = "https://example.com/source.tgz?token=xyz"

  deploymentData =
    staging:    JSON.parse(Fs.readFileSync("#{fixtureDir}/staging.json"))
    production: JSON.parse(Fs.readFileSync("#{fixtureDir}/production.json"))

  beforeEach () ->
    Nock.disableNetConnect()

    staging    = new HubotDeployGitHubDeployment(buildId, deploymentData.staging)
    production = new HubotDeployGitHubDeployment(buildId, deploymentData.production)

  it "creates builds", (done) ->
    VCR.play "/apps-hubot-builds-#{buildId}-success"
    deployment = new Deployment(production, "token", archiveUrl, logger)
    deployment.run (err, res, body) ->
      parsedBody = JSON.parse(body)
      assert.equal archiveUrl, parsedBody.source_blob.url
      assert.equal "v1.3.0", parsedBody.source_blob.version
      done()