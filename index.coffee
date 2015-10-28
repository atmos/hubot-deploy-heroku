Path = require 'path'

module.exports = (robot, scripts) ->
  robot.loadFile(Path.resolve(__dirname, "src", "scripts"), "tokens.coffee")
