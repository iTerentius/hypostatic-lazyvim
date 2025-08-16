-- lua/keymaps/splits.lua
local map = vim.keymap.set
local o = { silent = true, noremap = true }
map("n", "<C-h>", "<C-w>h", o)
map("n", "<C-j>", "<C-w>j", o)
map("n", "<C-k>", "<C-w>k", o)
map("n", "<C-l>", "<C-w>l", o)
