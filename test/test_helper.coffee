global.assert = require("chai").assert
require("chai").Assertion.includeStack = true
process.env.NODE_ENV = 'test'
process.env.REAPER_TIMEOUT = 10
