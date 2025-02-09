require "tools.class"

local ref = Class("Ref")

function Ref()
  return ref:super({
    current={}
  })
end

function ref:set(data)
  self.current = data
  return self
end

