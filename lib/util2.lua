--- Local utilities
--

Util2 = {}

--- Is obj an instance of class?
-- From https://stackoverflow.com/questions/45192939/lua-check-if-a-table-is-an-instance
--
function Util2.is_instance(obj, class)
    while obj do
        obj = getmetatable(obj)
        if class == obj then return true end
    end
    return false
end

return Util2
