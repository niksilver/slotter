--- All the banks, A-Z.
--

util = require 'lib/util'

Bank = include 'slotter/lib/Bank'

Banks = {}

--- Create a new array of empty banks A-Z.
--
function Banks:new()
    local obj = {}

    for i = 1, 26 do
        local name = string.char(string.byte('A') + i - 1)
        obj[i] = Bank:new(name)
    end

    self.__index = self
    return setmetatable(obj, self)
end

--- Get a new bank from a given bank.
--
-- @tparam Bank bank    A Bank, among our banks.
-- @tparam number delta    A delta.
-- @treturn Bank    Another bank, which is `d` from the given one.
--
function Banks:inc(bank, d)
    for i = 1, 26 do
        if self[i] == bank then
            local i2 = util.clamp(i+d, 1, 26)
            return self[i2]
        end
    end
    error("Could not find given bank: " .. tostring(bank))
end

return Banks
