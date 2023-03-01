lu = require 'lib/luaunit'

SampleManager = require 'lib/sample_manager'
util2 = require 'lib/util2'

function test_new()
    -- Check that a new sample manager can have a buffer of 345 seconds
    local sm = SampleManager:new(345)
    lu.assertEquals(sm.blength, 345)
end

function test_load()
    -- Try to load a good file
    local sm = SampleManager:new(345)

    audio = {
        file_info = function(filename)
            -- 1200 frames at 10/sec = 120 seconds duration
            return nil, 1200, 10
        end,
    }
    softcut = {
        buffer_read_mono = function() end
    }

    local sample = sm:load('my-example-file.wav')
    lu.assertTrue(util2.is_instance(sample, Sample))
    lu.assertEquals(sample.duration, 120)
end
