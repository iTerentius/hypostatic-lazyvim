-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

require("config.keymaps.tabgroups")

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit Insert Mode" })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==<CR>", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==<CR>", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move visual selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move visual selection up" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- vim.keymap.set("n", "<leader>ff", "<cmd> Telescope find_files <CR>")
-- vim.keymap.set("n", "<leader>fa", "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>")
-- vim.keymap.set("n", "<leader>fe", "<cmd> Telescope file_browser <CR>")
-- vim.keymap.set("n", "<leader>fw", "<cmd> Telescope live_grep <CR>")
-- vim.keymap.set("n", "<leader>fb", "<cmd> Telescope buffers <CR>")
-- vim.keymap.set("n", "<leader>fh", "<cmd> Telescope help_tags <CR>")
-- vim.keymap.set("n", "<leader>fo", "<cmd> Telescope oldfiles <CR>")
-- vim.keymap.set("n", "<leader>fc", "<cmd> Telescope colorschemes <CR>")
-- terminal
vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<CR>")
vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<CR>")
vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<CR>")
vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<CR>")
vim.keymap.set("t", "<C-Up>", "<cmd>resize -2<CR>")
vim.keymap.set("t", "<C-Down>", "<cmd>resize +2<CR>")
vim.keymap.set("t", "<C-Left>", "<cmd>vertical resize -2<CR>")
vim.keymap.set("t", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- Move current buffer left/right
-- vim.keymap.set("n", "<C-h>", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer left" })
-- vim.keymap.set("n", "<C-l>", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer right" })

