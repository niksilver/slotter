--- A tool to manage loading and playing samples into softcut.
-- Used because we need to track which is where, and
-- occasionally free up space.

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

return SampleManager
