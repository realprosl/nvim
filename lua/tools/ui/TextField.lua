require "tools.init"
require "tools.ui.ref"
require "tools.ui.div"

---@class Div : Class
---@field title string Título del campo de texto.
---@field prefix string Prefijo que se muestra antes del campo de texto.
---@field onchange function Función de callback que se ejecuta cuando cambia el valor del campo.
---@field bind State|any Estado enlazado para sincronizar el valor del campo.


---@param attrs? { value?: string[], title?:string, prefix?:string, onchange?:function, bind?:State|any, width?:string} Atributos para configurar el TextField.
---@return Div Retorna una instancia de `Div` que representa el campo de texto.
function TextField(attrs)
  attrs = attrs or {}
  local value = attrs["value"] or {}
  local title = attrs["title"] or ""
  local ref = Ref()
  local prefix = attrs["prefix"] or ">"
  local onchange = function() end
  local preonchange = attrs["onchange"] or function(_) end

  attrs["prefix"] = nil

  -- binding state
  if attrs["bind"] then

    local bind = attrs["bind"]
    attrs["bind"] = nil

    if InstanceOf(bind, "State") then
      onchange = function(self)
        preonchange(self)
        bind:set(self:getValue())
      end
    else
      onchange = preonchange
      print("not state")
    end
  end

  return Div({
    title = title,
    width= attrs.width or '50px',
    height='1px',
    ref = ref,
    border = "single",
    border_color = "#2596be",
    title_color = "#2596be",
    title_pos = "left",
    children = {
      Div({
        value = prefix,
        width = '3px',
        color = "#2596be",
      }),
      Div({
        value = value,
        width = '45px',
        col = '3px',
        keymap = {
          {
            mode = 'n',
            key = 'q',
            callback = function()
              ref.current:remove()
            end,
          },
        }
      })
      :addEventListener("TextChangedI", onchange)
    },
  })
end
