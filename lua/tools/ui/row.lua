require "tools.ui.div"
require "tools.flex_box"
require "tools.ui.getSize"
local parse = require "tools.parse"
--- TYPES ---
---@alias attrs { children: Div[], align?:'start'|'end'|'center'|'space_between'|'space_around',width?:string, height?:string }

--- UTILS ---

--- get total width of children 
---@type fun(children:Div[]):number
local getTotalWidhtChildren = function (children)
  local total = 0
  for _, child in ipairs(children) do
    total = total + child.attrs.width
  end
  return total
end

--- CLASS ROW ---
---@type fun(attrs:attrs):Div
function Row (attrs)
  local parent = Div({ width=attrs.width or '1px', height=attrs.height or '1px', children=attrs.children })
  parent:addAction(
    ---@type fun(Div)
    function (self)
    --- calculate sizes of children
    local offset = 2

    for index, child in ipairs(self.children) do
      if child.size.width == '1px' then
          self.children[index].attrs.width = math.floor(self.attrs.width/#self.children)
        else
          if parse.isPorcent(child.size.width) then
              self.children[index].attrs.width = (parse.str(child.size.width)*self.attrs.width/100)
            else
              self.children[index].attrs.width = parse.str(child.size.width)
          end
      end
      if child.size.height == '1px' then
          self.children[index].attrs.height = self.attrs.height - offset
        else
          if parse.isPorcent(child.size.height) then
              self.children[index].attrs.height = ( parse.str(child.size.height)*self.attrs.height/100 ) - offset
            else
              self.children[index].attrs.height = parse.str(child.size.height) - offset
          end
      end
    end

    if not attrs.align then
        attrs.align = "start"
    end

    local switch = {
        ['end'] = function ()
          local col = self.attrs.col + (self.attrs.width - getTotalWidhtChildren(attrs.children))
          for index, child in ipairs(attrs.children) do
            self.children[index].attrs.col = col
            self.children[index].attrs.row = self.attrs.row
            col = col + child.attrs.width + 2
          end
        end,

        ['start'] = function ()
          local col = self.attrs.col
          for index, child in ipairs(attrs.children) do
            self.children[index].attrs.col = col
            self.children[index].attrs.row = self.attrs.row
            col = col + child.attrs.width + 2
          end
        end,

        ['center'] = function ()
          local col = self.attrs.col + math.floor(((self.attrs.width - getTotalWidhtChildren(attrs.children))/2))
          for index, child in ipairs(attrs.children) do
            self.children[index].attrs.col = col
            self.children[index].attrs.row = self.attrs.row
            col = col + child.attrs.width + 2
          end
        end,

        ['space_between'] = function ()
          local gap = math.floor(((self.attrs.width - getTotalWidhtChildren(attrs.children))/#attrs.children))
          local col = self.attrs.col + (gap/2)
          for index, child in ipairs(attrs.children) do
            self.children[index].attrs.col = col
            self.children[index].attrs.row = self.attrs.row
            col = col + child.attrs.width + 2 + gap
          end
        end,
        ['space_around'] = function ()
        end,
      }
    switch[attrs.align]()


  end)
  return parent
end



