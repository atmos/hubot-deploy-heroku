module.exports.cassettes =
  '/apps-hubot-builds-01234567-89ab-cdef-0123-456789abcdef-failure':
    host: 'https://api.heroku.com:443'
    path: '/apps/hubot/builds'
    code: 401
    method: 'post'
    body: { }
  '/apps-hubot-builds-01234567-89ab-cdef-0123-456789abcdef-success':
    host: 'https://api.heroku.com:443'
    path: '/apps/hubot/builds'
    code: 201
    method: 'post'
    body:
      buildpacks: [ { "url": "https://github.com/heroku/heroku-buildpack-ruby" } ],
      created_at: "2012-01-01T12:00:00Z",
      id: "01234567-89ab-cdef-0123-456789abcdef",
      output_stream_url: "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef",
      source_blob:
        url: "https://example.com/source.tgz?token=xyz",
        version: "3c9f42c76"
      slug:
        id: "01234567-89ab-cdef-0123-456789abcdef"
      status: "pending",
      updated_at: "2012-01-01T12:00:00Z",
      user:
        id: "01234567-89ab-cdef-0123-456789abcdef",
        email: "username@example.com"
