require "tools.ui.div"
require "tools.flex_box"
require "tools.ui.getSize"
local parse = require "tools.parse"

--- get total width of children 
---@type fun(children:Div[]):number
local getTotalHeightChildren = function (children)
  local total = 0
  for _, child in ipairs(children) do
    total = total + child.attrs.height
  end
  return total
end

--- CLASS ROW ---
---@type fun(attrs:{ children: Div[], align?:'start'|'end'|'center'|'space_between'|'space_around',width?:string, height?:string }):Div
function Column (attrs)
  local parent = Div({ width=attrs.width or '1px', height=attrs.height or '1px', children=attrs.children })
  parent:addAction(
    ---@type fun(Div)
    function (self)
    --- calculate sizes of children
    local offset = 2

    for index, child in ipairs(self.children) do
      if child.size.height == '1px' then
          self.children[index].attrs.height = math.floor(self.attrs.height/#self.children)
        else
          if parse.isPorcent(child.size.height) then
              self.children[index].attrs.height = (parse.str(child.size.height)*self.attrs.height/100)
            else
              self.children[index].attrs.height = parse.str(child.size.height)
          end
      end

      if child.size.width == '1px' then
          self.children[index].attrs.width = self.attrs.width - offset
        else
          if parse.isPorcent(child.size.width) then
              self.children[index].attrs.width = ( parse.str(child.size.width)*self.attrs.width/100 ) - offset
            else
              self.children[index].attrs.width = parse.str(child.size.width) - offset
          end
      end
    end

    if not attrs.align then
        attrs.align = "start"
    end

    local switch = {
        ['end'] = function ()
          local row = self.attrs.row + (self.attrs.height - getTotalHeightChildren(attrs.children))
          for index, child in ipairs(attrs.children) do
            self.children[index].attrs.row = row
            self.children[index].attrs.col = self.attrs.col
            row = row + child.attrs.height + 2
          end
        end,

        ['start'] = function ()
          local row = self.attrs.row
          for index, child in ipairs(attrs.children) do
            self.children[index].attrs.row = row
            self.children[index].attrs.col = self.attrs.col
            row = row + child.attrs.height + 2
          end
        end,

        ['center'] = function ()
          local row = self.attrs.row + math.floor(((self.attrs.height - getTotalHeightChildren(attrs.children))/2))
          for index, child in ipairs(attrs.children) do
            self.children[index].attrs.row = row
            self.children[index].attrs.col = self.attrs.col
            row = row + child.attrs.height + 2
          end
        end,

        ['space_between'] = function ()
          local gap = math.floor(((self.attrs.height - getTotalHeightChildren(attrs.children))/#attrs.children))
          local row = self.attrs.row + (gap/2)
          for index, child in ipairs(attrs.children) do
            self.children[index].attrs.row = row
            self.children[index].attrs.col = self.attrs.col
            row = row + child.attrs.height + 2 + gap
          end
        end,
        ['space_around'] = function ()
        end,
      }
    switch[attrs.align]()


  end)
  return parent
end



