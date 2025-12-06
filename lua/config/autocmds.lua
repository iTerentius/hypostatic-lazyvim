-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- augroup Tidal
-- In your LazyVim config (e.g., lua/config/autocmds.lua)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "Tidal",
  callback = function()
    vim.bo.commentstring = "-- %s"
  end,
})

-- 2025-12-05 SCLang custom highlights (force-set on startup)
local sclang_hl = vim.api.nvim_create_augroup("sclang_highlights", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = sclang_hl,
  callback = function()
    vim.cmd([[
      highlight SCLangPdefn   guifg=#ff5555 gui=bold
      highlight SCLangPbindef guifg=#55aaff gui=bold
      highlight SCLangPdef    guifg=#55ff55 gui=bold
    ]])
  end,
})

