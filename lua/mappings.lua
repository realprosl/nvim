require "nvchad.mappings"
local log = require("notify")

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", {silent=true})
map("n","<leader>wq", ":wall<cr>:q<cr>", {silent=true})
map("n","<leader>w", ":w<cr>", {silent=true})
map("n","<leader>ww", ":wall<cr>", {silent=true , callback=function ()
  log("All files saved")
end})
map("n","<leader>q", ":q<cr>", {silent=true})
map("n","<leader>qq", ":q!<cr>", {silent=true})
-- oil
map("n","<leader>oo", ":Oil<cr>", {silent=true})


-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
