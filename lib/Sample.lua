--- A Sample is a snippet of audio.

Sample = {}

--- Make a new sample.
-- @tparam table props    Table of properties.
-- @treturn Sample    A new Sample object.
--
function Sample:new(props)
    local obj = {
        filename = props.filename,
        start = props.start or 0,
        duration = props.duration or 1.0,
    }
    self.__index = self
    return setmetatable(obj, self)
end

--- Filename on which the sample is based.
--
Sample.filename = ''

return Sample
