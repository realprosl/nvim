local class = {}
class.__index = class

function Class(type)
  local instance = {
    type=type
  }
  setmetatable(instance, class)

  instance.__index = instance

  return instance
end

function class:super(instance)
  setmetatable(instance,self)
  return instance
end

