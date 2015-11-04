Path   = require("path")

pkg = require Path.join __dirname, "..", "..", "package.json"
pkgVersion = pkg.version

VCR = require "ys-vcr"
HubotDeployHeroku = require Path.join __dirname, "..", "..", "src", "helpers"

BuildInfo     = HubotDeployHeroku.BuildInfo

describe "The build information", () ->
  info    = undefined
  buildId = "01234567-89ab-cdef-0123-456789abcdef"
  beforeEach () ->
    VCR.playback()
    info = new BuildInfo "token", "hubot", buildId
  afterEach () ->
    VCR.stop()

  it "handles pending builds", (done) ->
    VCR.play "/apps-hubot-builds-#{buildId}-pending"
    info.status (err, res, body) =>
      parsedBody = JSON.parse(body)
      assert.equal buildId, parsedBody.id
      assert.equal "pending", parsedBody.status
      done()

  it "handles successful builds", (done) ->
    VCR.play "/apps-hubot-builds-#{buildId}-succeeded"
    info.status (err, res, body) =>
      parsedBody = JSON.parse(body)
      assert.equal buildId, parsedBody.id
      assert.equal "succeeded", parsedBody.status
      done()

  it "handles pending builds", (done) ->
    VCR.play "/apps-hubot-builds-#{buildId}-failed"
    info.status (err, res, body) =>
      parsedBody = JSON.parse(body)
      assert.equal buildId, parsedBody.id
      assert.equal "failed", parsedBody.status
      done()

  it "handles bad authenticationbuilds", (done) ->
    VCR.play "/apps-hubot-builds-#{buildId}-bad-auth"
    info.status (err, res, body) =>
      parsedBody = JSON.parse(body)
      assert.equal "unauthorized", parsedBody.id
      assert.match parsedBody.message, /no credentials/
      done()


