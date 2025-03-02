require "tools.class"

---@class State : Class
---@field data  any
---@field subscribes function[]
---@field set fun(self:State, data:any)
---@field subscribe fun(self:State,callback:fun(any))
---@field emit fun(self:State)

---@type State
local state = Class("State")


---comment
---@param data any
---@return State
function State(data)

  return state:super({
    data=data,
    subscribes={}
  })

end


---@param data any
---@return nil
function state:set(data)
  if self.data ~= data then
    self.data = data
    self:emit()
  end
end


---@param callback fun(any)
---@return nil
function state:subscribe(callback)
  table.insert(self.subscribes, callback)
end


---@return nil
function state:emit()
  for _, item in ipairs(self.subscribes) do
    item(self.data or "")
  end
end

