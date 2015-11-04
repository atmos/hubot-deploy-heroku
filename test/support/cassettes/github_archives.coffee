module.exports.cassettes =

  '/repos-atmos-my-robot-archive-3c9f42c76-success':
    host: 'https://api.github.com'
    path: '/repos/atmos/my-robot/tarball/3c9f42c76'
    method: 'get'
    params:
      access_token: 'g-token'
    code: 302
    headers:
      Location: "https://example.com/source.tgz?token=xyz"
