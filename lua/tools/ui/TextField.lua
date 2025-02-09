require "tools.init"
require "tools.ui.ref"
require "tools.ui.div"

function TextField (attrs)
  local value = attrs["value"] or {}
  local title = attrs["title"] or ""
  local ref = Ref()
  local prefix = attrs["prefix"] or ">"
  local onchange = function ()end
  local preonchange = attrs["onchange"] or function (_) end

  attrs["prefix"] = nil

  -- binding state
  if attrs["bind"] then
    local bind = attrs["bind"]
    attrs["bind"] = nil

    if InstanceOf(bind,"State") then
        onchange = function (self)
          preonchange(self)
          bind:set(self:getValue())
        end
      else
        onchange = preonchange
        print("not state")
    end
  end


  return Div({
    title=title,
    ref=ref,
    align="center",
    border="single",
    border_color = "#2596be",
    title_color = "#2596be",
    title_pos = "left",
    children={
      Div({
        value=prefix,
        width=3,
        color="#2596be",
      }),
      Div({
        value=value,
        width=45,
        col=3,
        keymap={
          { mode='n',
            key='q',
            callback=function()
              ref.current:remove()
            end,
          },
        }
      })
      :addEventListener("TextChangedI", onchange )
    },
  })
end

