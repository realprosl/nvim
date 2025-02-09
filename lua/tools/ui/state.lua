require "tools.class"

local state = Class("State")

function State(data)

  return state:super({
    data=data,
    subscribes={}
  })

end

function state:set(data)
  if self.data ~= data then
    self.data = data
    self:emit()
  end
end

function state:subscribe(callback)
  table.insert(self.subscribes, callback)
end

function state:emit()
  for _, item in ipairs(self.subscribes) do
    item(self.data or "")
  end
end

