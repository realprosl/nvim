local str = require "lua_spand.strings"


---@type fun(value:string):boolean
local isPX = function(value)
  return str.endsWith(value, "px")
end

---@type fun(value:string):boolean
local isPorcent = function(value)
  return str.endsWith(value, "%")
end

  ---@type fun(value:string):number
 local px = function(value)
      local res = value:gsub("px","",1)
      local num = tonumber(res)
    return math.floor(num or 0)
  end

  ---@type fun(value:string):number
 local porcent = function(value)
      local res = value:gsub("%%","",1)
      local num = tonumber(res)
    return math.floor(num or 0)
  end

---@type fun(value:string):number
local parse = function (value)
  if isPX(value) then
    return px(value)
  elseif isPorcent(value) then
    return porcent(value)
  end
  return 0
end


return {
  str = parse,
  isPx = isPX,
  isPorcent = isPorcent,
}
