lu = require 'lib/luaunit'

SampleManager = require 'lib/sample_manager'

function test_new()
    local sm = SampleManager:new(345)
    lu.assertEquals(sm.blength, 345)
end
