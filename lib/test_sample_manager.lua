lu = require 'lib/luaunit'

SampleManager = require 'lib/sample_manager'
util2 = require 'lib/util2'

function setUp()
    softcut = nil
    audio = nil
end

function test_new()
    -- Check that a new sample manager can have a buffer of 345 seconds
    local sm = SampleManager:new(345)
    lu.assertEquals(sm.blength, 345)
end

function test_load()
    local sm, sample

    -- Load a good file

    sm = SampleManager:new(345)

    audio = {
        file_info = function(filename)
            -- 1200 frames at 10/sec = 120 seconds duration
            return nil, 1200, 10
        end,
    }
    softcut = {
        buffer_read_mono = function() end
    }

    sample = sm:load('my-example-file.wav')
    lu.assertTrue(util2.is_instance(sample, Sample))
    lu.assertEquals(sample.duration, 120)

    -- Load a file that's too long

    sm = SampleManager:new(345)

    audio = {
        file_info = function(filename)
            -- 4000 frames at 10/sec = 400 seconds duration
            return nil, 4000, 10
        end,
    }
    softcut = {
        buffer_read_mono = function() end
    }

    sample = sm:load('my-example-file.wav')
    lu.assertTrue(util2.is_instance(sample, Sample))
    lu.assertEquals(sample.duration, 345)

    -- Load a file that has no file info

    sm = SampleManager:new(345)

    audio = {
        file_info = function(filename)
            return 0, 0, 0
        end,
    }
    softcut = {
        buffer_read_mono = function() end
    }

    sample = sm:load('my-example-file.wav')
    lu.assertNil(sample)
end
