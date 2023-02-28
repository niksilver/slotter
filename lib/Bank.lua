--- A bank, which has 16 slots.
--

Bank = {}

--- Create a new, empty bank with a one-letter name.
-- @tparam string name    A single upper case letter.
function Bank:new(name)
    local obj = {
        bname = name,
        slots = {}
    }
    self.__index = self
    return setmetatable(obj, self)
end

--- The name of this bank (should be a single upper case letter).
--
function Bank:name()
    return self.bname
end

--- Array of 16 slots in the bank. Each element will be nil
-- or a Sample.
--
Bank.slots = {}

return Bank
