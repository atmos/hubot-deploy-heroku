Path   = require("path")

lib = require Path.join __dirname, "..", "index"
pkg = require Path.join __dirname, "..", "package.json"
pkgVersion = pkg.version

HerokuBuildInfo = lib.HerokuBuildInfo

describe "The hubot-deploy-heroku", () ->
  beforeEach () ->

  it "displays the version", () ->
    info = new HerokuBuildInfo "token", "hubot", "42"
    assert.equal "42", info.id
    assert.equal "token", info.apiToken
    assert.equal "hubot", info.appName
