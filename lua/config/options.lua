-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.winbar = "%=%m %f"
vim.g.autoformat = false
vim.opt.number = true
vim.opt.relativenumber = false
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- vim.opt. tabstop = 4
-- vim.opt. expandtab = true
-- vim.opt. softtabstop = 4
-- vim.opt. shiftwidth = 4
