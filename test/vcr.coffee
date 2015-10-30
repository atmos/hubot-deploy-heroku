nock = require('nock')

cassettes = { }

_ = require("underscore")
filenames = [ "heroku_account", "heroku_statuses", "github_statuses" ]
(cassettes = _.extend(cassettes, require("./support/cassettes/#{filename}").cassettes) for filename in filenames)
nock.disableNetConnect()

module.exports.get = (vcrName) ->
  cassettes[vcrName]

module.exports.play = (vcrName, times) ->
  cassette = cassettes[vcrName]
  path = vcrName
  method = cassette.method || 'get'
  if cassette.path
    path = cassette.path
  nock(cassette.host).filteringPath(/\?.*/g, '')[method](path).times(times or 1)
    .reply(cassette.code, cassette.body)

module.exports.stop = ->
  nock.cleanAll()

module.exports.playback = ->
  nock.disableNetConnect()
