require "tools.class"
require "tools.init"

-- ASSETS --  
local getSize = function(mode)
  if mode == "editor" then
    return {
      width= vim.o.columns,
      height= vim.o.lines
    }
  else
    return { width=0, height=0 }
  end
end


local div = Class("Div")

-- constructor
function Div(attrs)
  local instance = div:super({
    parent = nil,
    children = {},
    keymap = {},
    value = {},
    actions = {},
    ref = nil,
    buf = 0,
    align = "",
    background_color = "",
    border_color = "",
    title_color = "",
    color = "",
    attrs = {
      relative = "",
      col = 0,
      row = 0,
      width = 0,
      height = 0,
      border = "none",
      title = "",
      title_pos = "center",
      win = nil,
    },
  })

  -- fill and remove keys
  for _,key in pairs({"children","keymap","value","ref", "background_color","color", "border_color", "title_color", "align"}) do
    if key == "ref" then
      instance[key] = attrs[key]
    elseif string.sub(key,-5) == "color" or key == "align" then
      instance[key] = attrs[key] or ""
    else
      instance[key] = attrs[key] or {}
    end
    attrs[key] = nil
  end

  if instance.ref ~= nil then
    instance.ref:set(instance)
  end



  instance.attrs = attrs

  instance.attrs["relative"] = attrs["relative"] or "editor"
  instance.attrs["col"] = attrs["col"] or 0
  instance.attrs["row"] = attrs["row"] or 0
  instance.attrs["width"] = attrs["width"] or 50
  instance.attrs["height"] = attrs["height"] or 1
  instance.attrs["border"] = attrs["border"] or "none" -- { "none", "single", "double", "shadow", "rounded", "custom string"}
  instance.attrs["title"] = attrs["title"] or ""
  instance.attrs["title_pos"] = attrs["title_pos"] or "center" -- { "center", "right", "left"}

  if attrs["col"] == 0 and attrs["row"] == 0 and instance["align"] ~= ""  then

    local size = getSize(instance.attrs.relative)

    -- acum
    if instance["align"] == "center" then
      instance.attrs["col"] = math.floor(size.width/2 - instance.attrs.width/2)
      instance.attrs["row"] = math.floor(size.height/2 - instance.attrs.height/2)
    end
  end


    -- add parent
    for _, child in ipairs(instance.children) do
      child:add_parent(instance)
    end

  return instance
end

-- method add parennt inside instance
function div:add_parent(parent)
  self.parent = parent
  return self
end

-- get content inside buffer
function div:getValue()
  return vim.api.nvim_buf_get_lines(self.buf, 0, -1, true)
end

-- add event listener
function div:addEventListener(event, callback)
  self:addAction(function ()
    vim.api.nvim_create_autocmd({event}, {
        buffer=self.buf,
        callback = function ()
          callback(self)
        end,
    })
  end)
  return self
end

-- method render 
function div:render()

  if self.parent then
    self.attrs["relative"] = "win"
    self.attrs["win"] = self.parent.attrs.win
  end

  -- create buf and win
  self.buf = vim.api.nvim_create_buf(false, true) -- Crear un buffer no listado
  self.attrs.win = vim.api.nvim_open_win(self.buf, true, self.attrs) -- Crear la ventana flotante

  -- setting win
  vim.api.nvim_buf_set_option(self.buf, "number", false)  -- Desactivar numeración
  vim.api.nvim_buf_set_option(self.buf, "relativenumber", false)  -- Desactivar numerac
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "Normal:Normal") -- reset color hightlight
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "FloatBorder:NONE") -- reset border color hightlight
  vim.cmd('highlight FloatTitle guifg=NONE guibg=NONE') -- reset float title color

  -- keymap
  vim.api.nvim_buf_set_keymap(self.buf, 'n', 'q', "", { noremap=true, silent=true, callback=function () self:remove() end })

  -- init custom keymap
  for _, item in ipairs(self.keymap) do
      vim.api.nvim_buf_set_keymap(
        self.buf,
        item.mode or "",
        item.key or "",
        "",
        { noremap=true, silent=true, callback=function () item.callback(self) end }
      )
  end

  -- add content
  if InstanceOf(self.value, "State") then
      self:setValue(self.value.data)
      self.value:subscribe(function (data)
        self:setValue(data)
      end)
  else
    self:setValue(self.value)
  end

  -- set background_color
  if self.background_color ~= "" then
    self:setBackgroundColor(self.background_color)
  end

  -- set color
  if self.color ~= "" then
    self:setColor(self.color)
  end

  -- set border color
  if self.border_color ~= "" then
    self:setBorderColor(self.border_color)
  end

  -- set title color
  if self.title_color ~= "" then
    self:setTitleColor(self.title_color)
  end

  for _, action in ipairs(self.actions) do
    action()
  end

  -- rendering children
  for _, item in ipairs(self.children) do
    item:render()
  end

end

-- set background color
function div:setBackgroundColor(color)
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "Normal:background_color")
  vim.cmd(string.format("highlight background_color guibg=%s",color))
  return self
end

-- set color
function div:setColor(color)
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "Normal:color")
  vim.cmd(string.format("highlight color guifg=%s",color))
  return self
end

-- set border color
function div:setBorderColor(color)
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "FloatBorder:border_color")
  vim.cmd(string.format("highlight border_color guifg=%s",color))
  return self
end

-- set title color
function div:setTitleColor(color)
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "FloatTitle:title_color")
  vim.cmd(string.format("highlight title_color guifg=%s",color))
  return self
end

-- method add children
function div:addChild(child)
  table.insert(self.children, child)
  child:add_parent(self)
  return self
end

-- method remove 
function div:remove()
  for _, child in ipairs(self.children) do
    child:remove()
  end
  vim.api.nvim_win_close(self.attrs.win, true)
end

-- set content
function div:setValue(value)
  if type(value) == "string" then
    value = {value}
  end

  if self.buf == 0 then
    self.value = value
    else
    vim.api.nvim_buf_set_lines(self.buf,0,-1,false,value or {})
  end
  return self
end

-- movo cursor in window
function div:move(pos)
  if self.attrs.win then
    vim.api.nvim_win_set_cursor(self.attrs.win, pos or {})
  else
    table.insert(self.actions, function ()
      vim.api.nvim_win_set_cursor(self.attrs.win, pos or {})
    end)
  end
  return self
end

-- append action
function div:addAction(action)
  table.insert(self.actions, action)
  return self
end



