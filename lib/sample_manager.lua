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
-- The sample will be cut down if the file is too long.
-- @tparam string file    Full path name of the file.
-- @treturn Sample    The Sample object loaded, or nil if there was a problem.
--
function SampleManager:load(file)
    local channels, frames, samplerate = audio.file_info(file)

    local duration = 0
    if frames > 0 and samplerate > 0 then
        duration = frames / samplerate
    else
        -- Problem reading file data
        return nil
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

    local space = self:find_space(duration)
    local sample = Sample:new {
        filename = file,
        start = space.start,
        duration = space.duration,
    }
    table.insert(self.buffers[space.ch], space.idx, sample)

    return sample
end

--- Find some space in a buffer for a sample.
-- It will require a 0.25 second gap at either end.
-- @tparam dur    Number of seconds required.
-- @treturn table    A table of keys start, duration, ch, idx.
--     start: The start position of the space (after the front gap),
--         or nil if none found.
--     duration: The duration of the space available (which will be the full
--         duration unless the buffer is too short).
--     ch: The channel (buffer) where the space is found.
--     idx: Which index the buffer the sample will go.
--
function SampleManager:find_space(dur)
    local ch = 1

    if #(self.buffers[ch]) == 0 then
        return {
            start = 0.25,
            duration = math.min(dur, self.blength-0.5),
            ch = ch,
            idx = 1,
        }
    end

    local last = 0
    for i, samp in ipairs(self.buffers[ch]) do
        local free = samp.start - last
        if free >= dur + 0.5 then
            return {
                start = last + 0.25,
                duration = dur,
                ch = ch,
                idx = i
            }
        end
        last = samp.start + samp.duration + 0.25
    end
    -- We've reached the end of our samples. Is there more space at the end?
    local free = self.blength - last
    if free >= dur + 0.5 then
        return {
            start = last + 0.25,
            duration = dur,
            ch = ch,
            idx = #(self.buffers[ch]) + 1
        }
    end

    return { start = nil, duration = nil, ch = nil, idx = nil }
end

return SampleManager
