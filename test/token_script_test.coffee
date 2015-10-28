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

  it "sets your http token", (done) ->
    adapter.on "reply", (envelope, strings) ->
      console.log strings[0]
      expect(strings[0]).match(/Why hello there/)
      done()

    adapter.receive(new TextMessage(user, "deploy-token:set:heroku 123456789"))
