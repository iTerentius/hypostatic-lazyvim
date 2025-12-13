
-- lua/config/keymaps.lua

local map = vim.keymap.set

-- Create / manage tab *groups*
map("n", "<leader>tt", "<cmd>tab split<CR>",  { desc = "Tab: split current into new group" })
map("n", "<leader>tg", "<cmd>tabnew<CR>",    { desc = "Tab: new empty group" })
map("n", "<leader>tq", "<cmd>tabclose<CR>",  { desc = "Tab: close current group" })
map("n", "<leader>to", "<cmd>tabonly<CR>",   { desc = "Tab: keep only this group" })

-- Move between tab groups
map("n", "<C-Right>", "<cmd>tabnext<CR>",    { desc = "Tab: next group" })
map("n", "<C-Left>",  "<cmd>tabprevious<CR>",{ desc = "Tab: previous group" })

-- Direct jump: treat tab 1..9 as named groups
for i = 1, 9 do
  map("n", "<leader>" .. i, i .. "gt", { desc = "Tab group " .. i })
end
