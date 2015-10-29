module.exports.cassettes =
  '/apps-hubot-builds-01234567-89ab-cdef-0123-456789abcdef-pending':
    host: 'https://api.heroku.com:443'
    path: '/apps/hubot/builds/01234567-89ab-cdef-0123-456789abcdef'
    code: 200
    body:
      buildpacks: [ { "url": "https://github.com/heroku/heroku-buildpack-ruby" } ],
      created_at: "2012-01-01T12:00:00Z",
      id: "01234567-89ab-cdef-0123-456789abcdef",
      output_stream_url: "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef",
      source_blob:
        url: "https://example.com/source.tgz?token=xyz",
        version: "v1.3.0"
      slug:
        id: "01234567-89ab-cdef-0123-456789abcdef"
      status: "pending",
      updated_at: "2012-01-01T12:00:00Z",
      user:
        id: "01234567-89ab-cdef-0123-456789abcdef",
        email: "username@example.com"

  '/apps-hubot-builds-01234567-89ab-cdef-0123-456789abcdef-succeeded':
    host: 'https://api.heroku.com:443'
    path: '/apps/hubot/builds/01234567-89ab-cdef-0123-456789abcdef'
    code: 200
    body:
      buildpacks: [ { "url": "https://github.com/heroku/heroku-buildpack-ruby" } ],
      created_at: "2012-01-01T12:00:00Z",
      id: "01234567-89ab-cdef-0123-456789abcdef",
      output_stream_url: "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef",
      source_blob:
        url: "https://example.com/source.tgz?token=xyz",
        version: "v1.3.0"
      slug:
        id: "01234567-89ab-cdef-0123-456789abcdef"
      status: "succeeded",
      updated_at: "2012-01-01T12:00:00Z",
      user:
        id: "01234567-89ab-cdef-0123-456789abcdef",
        email: "username@example.com"

  '/apps-hubot-builds-01234567-89ab-cdef-0123-456789abcdef-failed':
    host: 'https://api.heroku.com:443'
    path: '/apps/hubot/builds/01234567-89ab-cdef-0123-456789abcdef'
    code: 200
    body:
      buildpacks: [ { "url": "https://github.com/heroku/heroku-buildpack-ruby" } ],
      created_at: "2012-01-01T12:00:00Z",
      id: "01234567-89ab-cdef-0123-456789abcdef",
      output_stream_url: "https://build-output.heroku.com/streams/01234567-89ab-cdef-0123-456789abcdef",
      source_blob:
        url: "https://example.com/source.tgz?token=xyz",
        version: "v1.3.0"
      slug:
        id: "01234567-89ab-cdef-0123-456789abcdef"
      status: "failed",
      updated_at: "2012-01-01T12:00:00Z",
      user:
        id: "01234567-89ab-cdef-0123-456789abcdef",
        email: "username@example.com"

  '/apps-hubot-builds-01234567-89ab-cdef-0123-456789abcdef-bad-auth':
    host: 'https://api.heroku.com:443'
    path: '/apps/hubot/builds/01234567-89ab-cdef-0123-456789abcdef'
    code: 401
    body:
      id: "unauthorized"
      message: "There were no credentials in your `Authorization` header. Try `Authorization: Bearer <OAuth access token>` or `Authorization: Basic <base64-encoded email + \":\" + password>`."
