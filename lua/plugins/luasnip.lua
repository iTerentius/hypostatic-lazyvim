-- ~/.config/nvim/lua/plugins/luasnip.lua
-- 2025-11-22: single canonical LuaSnip spec for LazyVim + SCNvim

return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  -- build = "make install_jsregexp", -- optional; improves regex snippet triggers
  config = function()
    local ok_ls, luasnip = pcall(require, "luasnip")
    if not ok_ls then
      return
    end

    -- sane defaults; doesn't affect blink keymaps
    luasnip.config.setup({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      enable_autosnippets = false,
      region_check_events = "InsertEnter",
      delete_check_events = "TextChanged,InsertLeave",
    })

    ------------------------------------------------------------------------
    -- 1. Load community VSCode-style snippets + your JSON snippets
    ------------------------------------------------------------------------
    local ok_vscode, vscode_loader = pcall(require, "luasnip.loaders.from_vscode")
    if ok_vscode then
      vscode_loader.lazy_load() -- friendly-snippets
      vscode_loader.lazy_load({
        paths = vim.fn.expand("~/.config/nvim/snippets"),
      })
    end

    ------------------------------------------------------------------------
    -- 2. Load your Lua-format snippets
    -- You said supercollider.lua is in ~/.config/nvim/lua/snippets/
    ------------------------------------------------------------------------
    local ok_lua, lua_loader = pcall(require, "luasnip.loaders.from_lua")
    if ok_lua then
      lua_loader.lazy_load({
        paths = vim.fn.expand("~/.config/nvim/lua/snippets"),
        -- include = { "supercollider" }, -- uncomment to restrict if desired
      })
    end

    ------------------------------------------------------------------------
    -- 3. Load SCNvim-generated snippets on SC buffers
    ------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "supercollider",
      callback = function()
        local ok_utils, utils = pcall(require, "scnvim.utils")
        if ok_utils then
          luasnip.add_snippets("supercollider", utils.get_snippets(), { key = "scnvim" })
        end
      end,
    })
  end,
}
