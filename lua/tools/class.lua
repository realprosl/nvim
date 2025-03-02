---@class Class : table
---@field type string
local class = {}
class.__index = class

---@param type string
---@return Class
function Class(type)
  local instance = {
    type = type
  }
  setmetatable(instance, class)

  instance.__index = instance

  return instance
end

---@param instance Class
---@return Class
function class:super(instance)
  setmetatable(instance, self)
  return instance
end
