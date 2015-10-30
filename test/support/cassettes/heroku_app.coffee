module.exports.cassettes =
  '/apps-hubot-pre-authorizations-success':
    host: 'https://api.heroku.com:443'
    path: '/apps/hubot/pre-authorizations'
    code: 200
    method: 'put'
    body: { }
  '/apps-hubot-pre-authorizations-failure':
    host: 'https://api.heroku.com:443'
    path: '/apps/hubot/pre-authorizations'
    code: 401
    method: 'put'
    body:
      id: "unauthorized"
      message: "Invalid credentials provided."
