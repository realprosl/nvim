
function GetColorGroup(group)
  -- Obtenemos el color del grupo de resaltado
  local highlight_info = vim.api.nvim_get_hl(0, {name=group})
  
  -- El tipo de color puede ser 'fg' (foreground) o 'bg' (background)
  return highlight_info
end

function InstanceOf(class, name)
  if type(class.type) == "string" then
    return class.type == name
  end
  return false
end

function CountBufferChars()
    local content = vim.api.nvim_buf_get_lines(0, 0, -1, false) -- Obtener todas las líneas del buffer
    local text = table.concat(content, "\n") -- Convertir líneas en un solo string
    local char_count = #text -- Contar caracteres
    vim.api.nvim_echo({{"Caracteres: " .. char_count, "None"}}, false, {}) -- Mostrar en la línea de comandos
end
