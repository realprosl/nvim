require "tools.class"

---@class Ref : Class
---@field current Class
---@field set fun(self:Ref, data:Class):Ref

---@type Ref
local ref = Class("Ref")

---@return Ref
function Ref()
  return ref:super({
    current={}
  })
end

---@param data any
---@return Ref
function ref:set(data)
  self.current = data
  return self
end
