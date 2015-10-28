Path        = require "path"
Robot       = require "hubot/src/robot"
TextMessage = require("hubot/src/message").TextMessage

describe "Setting tokens and such", () ->
  user  = null
  robot = null
  adapter = null

  beforeEach (done) ->
    robot = new Robot(null, "mock-adapter", true, "Hubot")

    robot.adapter.on "connected", () ->
      require("hubot-deploy")(robot)
      require("hubot-vault")(robot)
      require("hubot-help")(robot)
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

  it "displays help", (done) ->
    adapter.on "reply", (envelope, strings) ->
      expect(strings[0]).match(/Why hello there/)
      done()

    adapter.receive(new TextMessage(user, "Hubot help deploy"))

  it "tells you when your provided http token is invalid", (done) ->
    adapter.on "send", (envelope, strings) ->
      assert.match strings[0], /Sorry, your heroku token is invalid/
      done()
    adapter.receive(new TextMessage(user, "Hubot deploy-token:set:heroku 123456789"))
  it "tells you when your provided heroku token is valid", (done) ->
    adapter.on "send", (envelope, strings) ->
      assert.match strings[0], /Sorry, your heroku token is invalid/
      done()
    adapter.receive(new TextMessage(user, "Hubot deploy-token:set:heroku 123456789"))

  it "tells you when your stored heroku token is valid", (done) ->
    adapter.on "send", (envelope, strings) ->
      assert.match strings[0], /Sorry, your heroku token is invalid\. I removed it from memory/
      done()
    adapter.receive(new TextMessage(user, "Hubot deploy-token:verify:heroku"))
  it "tells you when your stored heroku token is valid", (done) ->
    adapter.on "send", (envelope, strings) ->
      assert.match strings[0], /Hey, atmos@atmos.org\. Your heroku token is valid\./
      done()
    adapter.receive(new TextMessage(user, "Hubot deploy-token:verify:heroku"))
