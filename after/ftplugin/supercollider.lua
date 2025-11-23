-- ~/.config/nvim/after/ftplugin/supercollider.lua
-- 2025-11-22: SC-only <Tab>/<S-Tab> for LuaSnip first, then blink menu nav, else literal tab.

local function apply_sc_tab_maps(bufnr)
  local ok_ls, luasnip = pcall(require, "luasnip")
  if not ok_ls then
    return
  end

  local ok_blink, blink = pcall(require, "blink.cmp")
  -- blink is optional; if missing, we just skip its checks

  -- Always clear any buffer-local Tab maps first
  pcall(vim.keymap.del, "i", "<Tab>", { buffer = bufnr })
  pcall(vim.keymap.del, "i", "<S-Tab>", { buffer = bufnr })

  -- <Tab>: LuaSnip expand/jump -> blink next -> literal tab
  vim.keymap.set("i", "<Tab>", function()
    if luasnip.expand_or_jumpable() then
      return "<Plug>luasnip-expand-or-jump"
    end
    if ok_blink and blink.is_visible() then
      return "<C-n>"
    end
    return "<Tab>"
  end, {
    buffer = bufnr,
    expr = true,
    noremap = true,
    silent = true,
    replace_keycodes = true,
    desc = "SC Tab: LuaSnip > blink next > tab",
  })

  -- <S-Tab>: LuaSnip jump back -> blink prev -> literal shift-tab
  vim.keymap.set("i", "<S-Tab>", function()
    if luasnip.jumpable(-1) then
      return "<Plug>luasnip-jump-prev"
    end
    if ok_blink and blink.is_visible() then
      return "<C-p>"
    end
    return "<S-Tab>"
  end, {
    buffer = bufnr,
    expr = true,
    noremap = true,
    silent = true,
    replace_keycodes = true,
    desc = "SC S-Tab: LuaSnip prev > blink prev > shift-tab",
  })
end

-- Apply immediately for this buffer
local bufnr = vim.api.nvim_get_current_buf()
apply_sc_tab_maps(bufnr)

-- Re-apply on InsertEnter to override late/other plugin maps
vim.api.nvim_create_autocmd("InsertEnter", {
  buffer = bufnr,
  callback = function()
    apply_sc_tab_maps(bufnr)
  end,
})

