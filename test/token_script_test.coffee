Path        = require "path"
Robot       = require "hubot/src/robot"
TextMessage = require("hubot/src/message").TextMessage
helpers     = require("../src/helpers")
VCR         = require "./vcr"

describe "Setting tokens and such", () ->
  user  = null
  robot = null
  adapter = null

  beforeEach (done) ->
    process.env.HUBOT_FERNET_SECRETS or= "HSfTG4uWzw9whtlLEmNAzscHh96eHUFt3McvoWBXmHk="
    robot = new Robot(null, "mock-adapter", true, "Hubot")

    robot.adapter.on "connected", () ->
      require("hubot-deploy")(robot)
      require("hubot-vault")(robot)
      require("../index")(robot)

      userInfo =
        name: "atmos",
        room: "#my-heroku-room"

      user    = robot.brain.userForId "1", userInfo
      adapter = robot.adapter

      done()

    robot.run()

  afterEach () ->
    robot.server.close()
    robot.shutdown()

  it "tells you when your provided heroku token is invalid", (done) ->
    adapter.on "send", (envelope, strings) ->
      assert.match strings[0], /Sorry, your heroku token is invalid/
      done()
    adapter.receive(new TextMessage(user, "Hubot deploy-token:set:heroku 123456789"))

  it "tells you when your provided heroku token is valid", (done) ->
    VCR.play "/account valid"
    expectedResponse = /Hey, username@example.com. Your heroku token is valid. I stored it for future use./
    adapter.on "send", (envelope, strings) ->
      assert.match strings[0], expectedResponse
      done()
    adapter.receive(new TextMessage(user, "Hubot deploy-token:set:heroku 123456789"))

  it "store your valid token", (done) ->
    VCR.play "/account valid"
    expectedResponse = /Hey, username@example.com. Your heroku token is valid. I stored it for future use./
    adapter.on "send", (envelope, strings) ->
      assert robot.vault.forUser(user).get(helpers.TokenKey), "123456789"
      done()
    adapter.receive(new TextMessage(user, "Hubot deploy-token:set:heroku 123456789"))


  it "tells you when your stored heroku token is valid", (done) ->
    adapter.on "send", (envelope, strings) ->
      assert.match strings[0], /Sorry, your heroku token is invalid\. I removed it from memory/
      done()
    adapter.receive(new TextMessage(user, "Hubot deploy-token:verify:heroku"))

  it "tells you when your stored heroku token is valid", (done) ->
    VCR.play "/account valid"
    adapter.on "send", (envelope, strings) ->
      assert.match strings[0], /Hey, username@example.com\. Your heroku token is still valid\./
      done()
    adapter.receive(new TextMessage(user, "Hubot deploy-token:verify:heroku"))
