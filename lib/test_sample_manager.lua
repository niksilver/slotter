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
    -- Should be cut down by 0.25 seconds at either end
    lu.assertEquals(sample.duration, 345 - 0.5)

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

--[[function test_load_multiple()
    local sm, sample1, sample2

    -- Loading two short files should ensure they don't overlap

    sm = SampleManager:new(10)

    audio = {
        file_info = function(filename)
            -- Same for both samples
            -- 45 frames at 10/sec = 4.5 seconds duration
            return nil, 45, 10
        end,
    }
    softcut = {
        buffer_read_mono = function() end
    }

    sample1 = sm:load('sample1.wav')
    sample2 = sm:load('sample2.wav')

    -- To be completed!
end--]]

function test_find_space()
    local sm

    -- Simple case: find a space in an empty buffer

    sm = SampleManager:new(10)
    local space1 = sm:find_space(4)
    lu.assertEquals(space1.start, 0.25)
    lu.assertEquals(space1.duration, 4)
    lu.assertEquals(space1.ch, 1)
    lu.assertEquals(space1.idx, 1)

    -- Find spaces for two short samples

    sm = SampleManager:new(10)
    audio = {
        file_info = function(filename)
            -- 400 frames and 100/s is 4 seconds duration
            return 0, 400, 100
        end,
    }
    softcut = {
        buffer_read_mono = function() end
    }

    local space2_1 = sm:find_space(4)
    -- Runs from 0.25 to 4.25
    lu.assertEquals(space2_1.start, 0.25)
    lu.assertEquals(space2_1.duration, 4)
    lu.assertEquals(space2_1.ch, 1)
    lu.assertEquals(space2_1.idx, 1)
    sm:load('somesample.wav')

    local space2_2 = sm:find_space(4)
    -- Runs from 4.75 to 8.75
    lu.assertEquals(space2_2.start, 4.75)
    lu.assertEquals(space2_2.duration, 4)
    lu.assertEquals(space2_2.ch, 1)
    lu.assertEquals(space2_2.idx, 2)

    -- Find spaces for four short samples

    sm = SampleManager:new(10)
    audio = {
        file_info = function(filename)
            -- 100 frames and 100/s is 1 second duration
            return 0, 100, 100
        end,
    }
    softcut = {
        buffer_read_mono = function() end
    }

    local space3_1 = sm:find_space(1)
    -- Runs from 0.25 to 1.25
    lu.assertEquals(space3_1.start, 0.25)
    lu.assertEquals(space3_1.duration, 1)
    lu.assertEquals(space3_1.ch, 1)
    lu.assertEquals(space3_1.idx, 1)
    sm:load('somesample1.wav')

    local space3_2 = sm:find_space(1)
    -- Runs from 1.75 to 2.75
    lu.assertEquals(space3_2.start, 1.75)
    lu.assertEquals(space3_2.duration, 1)
    lu.assertEquals(space3_2.ch, 1)
    lu.assertEquals(space3_2.idx, 2)
    sm:load('somesample2.wav')

    local space3_3 = sm:find_space(1)
    -- Runs from 3.25 to 4.25
    lu.assertEquals(space3_3.start, 3.25)
    lu.assertEquals(space3_3.duration, 1)
    lu.assertEquals(space3_3.ch, 1)
    lu.assertEquals(space3_3.idx, 3)
    sm:load('somesample3.wav')

    local space3_4 = sm:find_space(1)
    -- Runds from 4.75 to 5.75
    lu.assertEquals(space3_4.start, 4.75)
    lu.assertEquals(space3_4.duration, 1)
    lu.assertEquals(space3_4.ch, 1)
    lu.assertEquals(space3_4.idx, 4)
end
