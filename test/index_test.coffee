Path   = require("path")

pkg = require Path.join __dirname, "..", "package.json"
pkgVersion = pkg.version

HubotDeployHeroku = require Path.join __dirname, "..", "index"

BuildInfo     = HubotDeployHeroku.BuildInfo
TokenVerifier = HubotDeployHeroku.TokenVerifier

describe "The hubot-deploy-heroku", () ->
  beforeEach () ->

  it "knows about build information", () ->
    info = new BuildInfo "token", "hubot", "42"
    assert.equal "42", info.id
    assert.equal "token", info.apiToken
    assert.equal "hubot", info.appName

  it "knows about token verification", () ->
    verifier = new TokenVerifier "token"
    assert.equal "token", verifier.apiToken
