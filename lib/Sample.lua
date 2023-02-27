--- A Sample is a snippet of audio.

Sample = {}

--- Make a new sample.
-- @tparam table props    Table of properties.
-- @treturn Sample    A new Sample object.
--
function Sample:new(props)
    local obj = {
        filename = '/home/we/dust/audio/tape/carnage1.wav',
        bank = props.bank or 'Z',
        slot = props.slot or 16,
        level = props.level or 1.0,
        rate = props.rate or 1.0,
        start = props.start or 0,
        duration = props.duration or 1.0,
    }
    self.__index = self
    return setmetatable(obj, self)
end

return Sample
