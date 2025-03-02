
---@alias relaive_mode "editor" | "win"
---@param mode relaive_mode
---@param win? number | nil
---@return { width:number, height:number }
---
function GetSize(mode, win)
  if mode == "editor" then
    return {
      width = vim.o.columns,
      height = vim.o.lines
    }
  else
    if win ~= nil then
      return {
        width = vim.api.nvim_win_get_width(win),
        height = vim.api.nvim_win_get_height(win)
      }
    else
      return { width = 0, height = 0 }
    end
  end
end
