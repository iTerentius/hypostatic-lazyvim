-- -- lua/keymaps/splits.lua
-- local map = vim.keymap.set
-- local o = { silent = true, noremap = true }
-- map("n", "<C-h>", "<C-w>h", o)
-- map("n", "<C-j>", "<C-w>j", o)
-- map("n", "<C-k>", "<C-w>k", o)
-- map("n", "<C-l>", "<C-w>l", o)
-- 2025-12-13

-- lua/config/keymaps/sc-splits.lua
-- 2025-12-13

local group = vim.api.nvim_create_augroup("SCNvimKeyOverrides", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "supercollider", -- this is the actual filetype for .scd
  callback = function(ev)
    vim.schedule(function()
      local map = vim.keymap.set

      -- remove scnvim's buffer-local <C-k>
      pcall(vim.keymap.del, "n", "<C-k>", { buffer = ev.buf })

      -- restore window navigation in SC buffers
      map("n", "<C-h>", "<C-w>h", { buffer = ev.buf, desc = "Win left", noremap = true, silent = true })
      map("n", "<C-j>", "<C-w>j", { buffer = ev.buf, desc = "Win down", noremap = true, silent = true })
      map("n", "<C-k>", "<C-w>k", { buffer = ev.buf, desc = "Win up", noremap = true, silent = true })
      map("n", "<C-l>", "<C-w>l", { buffer = ev.buf, desc = "Win right", noremap = true, silent = true })

      -- move signature help elsewhere
      map("n", "gK", function()
        require("scnvim.signature").show()
      end, { buffer = ev.buf, desc = "SC signature show" })
    end)
  end,
})
