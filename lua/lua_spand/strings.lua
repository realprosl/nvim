return{
  ---@type fun(str:string, suffix:string):boolean
  endsWith = function(str, suffix)
      local len_str = #str
      local len_sufijo = #suffix

      -- Si el sufijo es más largo que el string, no puede ser un sufijo
      if len_sufijo > len_str then
          return false
      end

      -- Extrae la parte final del string con la misma longitud que el sufijo
      local final_str = string.sub(str, len_str - len_sufijo + 1, len_str)

      -- Compara la parte final con el sufijo
      return final_str == suffix
  end
}


