-- return {
--   "L3MON4D3/LuaSnip",
--   dependencies = { "rafamadriz/friendly-snippets" },
--   -- build = "make install_jsregexp", -- optional; improves regex-based snippets
--   config = function()
--     -- Load community VSCode-style snippets (safe pcall)
--     local ok_loader, vscode_loader = pcall(require, "luasnip.loaders.from_vscode")
--     if ok_loader and vscode_loader then
--       vscode_loader.lazy_load()
--     end
--
--     -- Load SCNvim-generated snippets when entering a SuperCollider buffer
--     vim.api.nvim_create_autocmd("FileType", {
--       pattern = "supercollider",
--       callback = function(args)
--         local ok_ls, luasnip = pcall(require, "luasnip")
--         if not ok_ls then
--           return
--         end
--         local ok_utils, utils = pcall(require, "scnvim.utils")
--         if not ok_utils then
--           return
--         end
--         -- Use a key to avoid duplicates if you re-enter buffers
--         luasnip.add_snippets("supercollider", utils.get_snippets(), { key = "scnvim" })
--       end,
--     })
--   end,
-- }
return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  -- build = "make install_jsregexp", -- optional; improves regex-based snippets
  config = function()
    local ok_ls, luasnip = pcall(require, "luasnip")
    if not ok_ls then
      return
    end

    ------------------------------------------------------------------------
    -- 1. Load community VSCode-style snippets
    ------------------------------------------------------------------------
    local ok_vscode, vscode_loader = pcall(require, "luasnip.loaders.from_vscode")
    if ok_vscode then
      vscode_loader.lazy_load()
      -- Also load your own VSCode-format JSON snippets
      vscode_loader.lazy_load({ paths = "~/.config/nvim/snippets" })
    end

    ------------------------------------------------------------------------
    -- 2. Load your Lua-format snippets
    ------------------------------------------------------------------------
    local ok_lua, lua_loader = pcall(require, "luasnip.loaders.from_lua")
    if ok_lua then
      lua_loader.load({ paths = "~/.config/nvim/lua/snippets" })
    end

    ------------------------------------------------------------------------
    -- 3. Load SCNvim-generated snippets when entering SuperCollider buffers
    ------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "supercollider",
      callback = function(args)
        local ok_utils, utils = pcall(require, "scnvim.utils")
        if not ok_utils then
          return
        end
        luasnip.add_snippets("supercollider", utils.get_snippets(), { key = "scnvim" })
      end,
    })
  end,
}
