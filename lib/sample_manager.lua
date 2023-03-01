--- A tool to manage loading and playing samples into softcut.
-- Used because we need to track which is where, and
-- occasionally free up space.

Sample = require 'lib/Sample'

SampleManager = {}

--- Length of a buffer.
--
SampleManager.blength = nil

--- Create a new manager.
-- @tparam number buffer_length    Length of each softcut buffer, in seconds.
--     May be nil, in which case it will be read from the system.
--
function SampleManager:new(buffer_length)
    local obj = {
        blength = buffer_length or softcut.BUFFER_SIZE,
        buffers = { {}, {} },    -- Which samples are in the two buffers, ordered
    }
    self.__index = self
    return setmetatable(obj, self)
end

--- Load a file into a buffer, return a sample.
-- @tparam string file    Full path name of the file.
-- @treturn Sample    The Sample object loaded, or nil if there was a problem.
--
function SampleManager:load(file)
    local channels, frames, samplerate = audio.file_info(file)

    local duration = 0
    if frames > 0 and samplerate > 0 then
        duration = frames / samplerate
    end

    softcut.buffer_read_mono(file,
        0,    -- Source start
        0,    -- Buffer start
        -1,    -- Duration (-1 = read as much as possible)
        1,    -- Source channel
        1,    -- Buffer channel
        0,    -- Preserve level
        1.0    -- Level of new material
    )

    return Sample:new {
        filename = file,
        level = 1.0,
        rate = 1.0,
        start = 0,
        duration = duration,
    }
end

return SampleManager
