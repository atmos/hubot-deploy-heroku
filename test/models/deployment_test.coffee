Log = require "log"

VCR  = require "./../vcr"
Path = require "path"
Nock = require "nock"
Package = require Path.join __dirname, "..", "..", "package.json"
Version = Package.version

HubotDeployHeroku = require Path.join __dirname, "..", "..", "src", "helpers"
Deployment        = HubotDeployHeroku.Deployment

describe "The build information", () ->
  logger = new Log process.env.HUBOT_LOG_LEVEL or 'info'
  buildId    = "01234567-89ab-cdef-0123-456789abcdef"
  deployment = undefined

  beforeEach () ->
    Nock.disableNetConnect()

  it "handles pending builds", (done) ->
    VCR.play "/apps-hubot-builds-#{buildId}-pending"
    deployment = new Deployment(null, "token", "http://example.com/foo.tgz", logger)

