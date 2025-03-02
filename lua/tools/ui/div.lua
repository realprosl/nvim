require "tools.class"
require "tools.init"
local parse = require "tools.parse"

---@alias win_attrs { relative:string, col:number, row:number, width:number, height:number, border:string, title:string, title_pos:string, win:number|nil, winblend:number, zindex:number }

---@class Div
---@field parent Div|nil
---@field children Div[]
---@field keymap table[]
---@field value string[]|State
---@field actions function[]
---@field ref any
---@field buf number
---@field align string
---@field background_color string
---@field border_color string
---@field title_color string
---@field color string
---@field size { width:string, height:string }
---@field position { col:string, row:string }
---@field winblend number
---@field attrs win_attrs


---@class Div
local div = Class("Div")



---@param attrs { parent:Div|nil, children:Div[], keymap:{}, value:string[], actions:function[], ref:Ref|nil, buf:number, background_color:string, border_color:string, title_color:string, color:string, attrs:win_attrs, width:string, height:string, row:string, col:string, winblend:number, zindex:number }
---@return Div
function Div(attrs)
  ---@type Div
  local instance = div:super({
    parent = nil,
    children = {},
    keymap = {},
    value = {},
    actions = {},
    ref = nil,
    buf = 0,
    background_color = "",
    border_color = "",
    title_color = "",
    color = "",
    position = { col='0px', row='0px'},
    size = { width='0px', height='0px' },
    winblend = nil,
    attrs = {
      relative = "",
      col = 0,
      row = 0,
      width = 1,
      height = 1,
      border = "none",
      title = "",
      title_pos = "center",
      win = nil,
    },
  })

  -- fill and remove keys
  for _, key in pairs({ "children", "keymap", "value", "ref", "background_color", "color", "border_color", "title_color" }) do
    if key == "ref" then
      instance[key] = attrs[key]
    elseif string.sub(key, -5) == "color"  then
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

  instance.position["col"] = attrs["col"] or "0px"
  instance.position["row"] = attrs["row"] or "0px"
  instance.size["width"] = attrs["width"] or "1px"
  instance.size["height"] = attrs["height"] or "1px"
  instance.attrs["col"] = parse.str(instance.position.col)
  instance.attrs["row"] = parse.str(instance.position.row)
 
  if attrs.winblend then instance.winblend = attrs.winblend end
  if attrs.zindex then instance.attrs.zindex = attrs.zindex end

  local width = parse.str(instance.size.width) 
  if width == 0 then instance.attrs['width'] = 1 else instance.attrs['width'] = width end

  local height = parse.str(instance.size.height)
  if height == 0 then instance.attrs['height'] = 1 else instance.attrs['height'] = height end
  instance.attrs["relative"] = attrs["relative"] or "editor"
  instance.attrs["border"] = attrs["border"] or "none" -- { "none", "single", "double", "shadow", "rounded", "custom string"}
  instance.attrs["title"] = attrs["title"] or ""
  instance.attrs["title_pos"] = attrs["title_pos"] or "center" -- { "center", "right", "left"}

  -- delete key valueas
  instance.attrs.winblend = nil

  -- add parent
  for _, child in ipairs(instance.children) do
    child:add_parent(instance)
  end


  return instance
end

---@param parent Div
---@return Div
function div:add_parent(parent)
  self.parent = parent
  return self
end

---@return string[]
function div:getValue()
  return vim.api.nvim_buf_get_lines(self.buf, 0, -1, true)
end

---@param event string
---@param callback function
---@return Div
function div:addEventListener(event, callback)
  self:addAction(function()
    vim.api.nvim_create_autocmd({ event }, {
      buffer = self.buf,
      callback = function()
        callback(self)
      end,
    })
  end)
  return self
end

---@return nil
function div:render()
  if self.parent then
    self.attrs["relative"] = "win"
    self.attrs["win"] = self.parent.attrs.win
  end

  -- calculate size and position

  -- create buf and win
  self.buf = vim.api.nvim_create_buf(false, true) -- Crear un buffer no listado
  print("div::render::self.attrs.row: ",self.attrs.row)
  self.attrs.win = vim.api.nvim_open_win(self.buf, true, self.attrs) -- Crear la ventana flotante

  -- setting win
  vim.api.nvim_buf_set_option(self.buf, "number", false)  -- Desactivar numeración
  vim.api.nvim_buf_set_option(self.buf, "relativenumber", false)  -- Desactivar numerac
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "Normal:Normal") -- reset color hightlight
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "FloatBorder:NONE") -- reset border color hightlight
  vim.cmd('highlight FloatTitle guifg=NONE guibg=NONE') -- reset float title color

  -- keymap
  vim.api.nvim_buf_set_keymap(self.buf, 'n', 'q', "", { noremap = true, silent = true, callback = function() self:remove() end })

  -- init custom keymap
  for _, item in ipairs(self.keymap) do
    vim.api.nvim_buf_set_keymap(
      self.buf,
      item.mode or "",
      item.key or "",
      "",
      { noremap = true, silent = true, callback = function() item.callback(self) end }
    )
  end

  -- add content
  if InstanceOf(self.value, "State") then
    self:setValue(self.value.data)
    self.value:subscribe(function(data)
      self:setValue(data)
    end)
  else
    self:setValue(self.value)
  end

  --set transparance
  if self.winblend then
    print("div::winblend: ", self.winblend)
    vim.api.nvim_win_set_option(self.attrs.win,'winblend', self.winblend)
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
    action(self)
  end

  -- rendering children
  for _, item in ipairs(self.children) do
    item:render()
  end
end

---@param color string
---@return Div
function div:setBackgroundColor(color)
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "Normal:background_color")
  vim.cmd(string.format("highlight background_color guibg=%s", color))
  return self
end

---@param color string
---@return Div
function div:setColor(color)
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "Normal:color")
  vim.cmd(string.format("highlight color guifg=%s", color))
  return self
end

---@param color string
---@return Div
function div:setBorderColor(color)
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "FloatBorder:border_color")
  vim.cmd(string.format("highlight border_color guifg=%s", color))
  return self
end

---@param color string
---@return Div
function div:setTitleColor(color)
  vim.api.nvim_win_set_option(self.attrs.win, "winhl", "FloatTitle:title_color")
  vim.cmd(string.format("highlight title_color guifg=%s", color))
  return self
end

---@param child Div
---@return Div
function div:addChild(child)
  table.insert(self.children, child)
  child:add_parent(self)
  return self
end

---@return nil
function div:remove()
  for _, child in ipairs(self.children) do
    child:remove()
  end
  vim.api.nvim_win_close(self.attrs.win, true)
end

---@param value string|string[]
---@return Div
function div:setValue(value)
  if type(value) == "string" then
    value = { value }
  end

  if self.buf == 0 then
    self.value = value
  else
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, value or {})
  end
  return self
end

---@param pos number[]
---@return Div
function div:move(pos)
  if self.attrs.win then
    vim.api.nvim_win_set_cursor(self.attrs.win, pos or {})
  else
    table.insert(self.actions, function()
      vim.api.nvim_win_set_cursor(self.attrs.win, pos or {})
    end)
  end
  return self
end

---@param action fun(Div)
---@return Div
function div:addAction(action)
  table.insert(self.actions, action)
  return self
end
