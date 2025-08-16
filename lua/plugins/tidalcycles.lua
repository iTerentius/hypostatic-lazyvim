-- ~/.config/nvim/lua/plugins/vim-tidal.lua
return {
  {
    "tidalcycles/vim-tidal",
    ft = "tidal",
    init = function()
      -- keep terminal target; no need for tmux
      vim.g.tidal_target = "terminal" -- default anyway
      -- DO NOT set vim.g.tidal_no_mappings here
      -- Temporarily DO NOT set vim.g.tidal_boot (use fallback)
    end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tidal",
        callback = function(ev)
          -- free Ctrl-H (plugin maps hush to <C-h> by default)
          pcall(vim.keymap.del, "n", "<C-h>", { buffer = ev.buf })
          -- put hush somewhere else
          vim.keymap.set("n", "<leader>th", ":TidalHush<CR>", { buffer = ev.buf, silent = true, desc = "Tidal: Hush" })
        end,
      })
    end,
  },
}

-- return {
--   {
--     "tidalcycles/vim-tidal",
--     ft = "tidal",
--     init = function()
--       vim.g.tidal_boot = vim.fn.expand("~/Music/tidal/_boot/BootTidal.hs")
--       vim.g.tidal_boot_fallback = vim.g.tidal_boot
--       vim.g.tidal_target = "terminal" -- or "tmux"
--       vim.g.maplocalleader = "," -- enables default <localleader> maps too
--     end,
--     keys = {
--       -- send current line or visual selection
--       {
--         "<leader>ts",
--         "<Plug>TidalSendLine",
--         mode = { "n", "v" },
--         remap = true,
--         desc = "Tidal: Send line/selection",
--       },
--       -- send current paragraph/block
--       { "<leader>tb", "<Plug>TidalSendParagraph", mode = "n", remap = true, desc = "Tidal: Send paragraph" },
--       -- hush
--       { "<leader>th", "<Plug>TidalHush", mode = "n", remap = true, desc = "Tidal: Hush" },
--     },
--     vim.api.nvim_create_autocmd("FileType", {
--       pattern = "tidal",
--       callback = function(ev)
--         vim.keymap.set("n", "<leader>th", ":TidalHush<CR>", { buffer = ev.buf, silent = true, desc = "Tidal: Hush" })
--       end,
--     }),
--   },
-- }
