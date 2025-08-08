-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit Insert Mode" })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==<CR>", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==<CR>", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move visual selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move visual selection up" })
