# Description
#   Enable deployment statuses from the GitHub API
#
# Commands:
#   hubot deploy-hooks:sync - Sets your user's deployment token. Requires repo_deployment scope.
#
tokenKey = "hubot-deploy-heroku-secret"

Crypto  = require "crypto"
Helpers = require "./../helpers"

module.exports = (robot) ->
  robot.respond /deploy-token:set:heroku (.*)/i, (msg) ->
    token = msg.match[1]

    user  = robot.brain.userForId msg.envelope.user.id
    unless user?.id.match(/\d+/)
      msg.send "Yo, in the future you can private message to talk about heroku keys."

    verifier = new Helpers.TokenVerifier(token)
    verifier.valid (result) ->
      if result
        vault = robot.vault.forUser(user)
        vault.set tokenKey, token
        msg.send "Hey, #{result.email}. Your heroku token is valid. I stored it for future use."
      else
        msg.send "Sorry, your heroku token is invalid."

  robot.respond /deploy-token:verify:heroku$/i, (msg) ->
    user  = robot.brain.userForId msg.envelope.user.id
    unless user?.id.match(/\d+/)
      return msg.send "Sorry, can you private message me to talk about heroku keys?"

    vault = robot.vault.forUser(user)
    token = vault.get tokenKey

    if token?
      hashedToken = Crypto.createHash("sha1").update(token).digest("hex")
      robot.logger.info "#{user.id}-#{user.name} heroku token hash: #{hashedToken}."

    verifier = new Helpers.TokenVerifier(token)
    verifier.valid (result) ->
      if result
        msg.send "Hey, #{result.email}. Your heroku token is still valid."
      else
        vault.unset tokenKey
        msg.send "Sorry, your heroku token is invalid. I removed it from memory."

  robot.respond /deploy-token:reset:heroku/i, (msg) ->
    user = robot.brain.userForId msg.envelope.user.id
    unless user?.id.match(/\d+/)
      return msg.send "Sorry, can you private message me to talk about keys?"

    vault = robot.vault.forUser(user)
    token = vault.get tokenKey
    if token?
      hashedToken = Crypto.createHash("sha1").update(token).digest("hex")
      robot.logger.info "Unsetting #{user.id}-#{user.name} heroku token hash: #{hashedToken}."
    vault.unset tokenKey
    msg.send "Yo, I nuked your heroku token. You won't be able to deploy until you add a new one."
