-- ~/.config/nvim/lua/plugins/luasnip.lua
return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  -- event = "InsertEnter", -- optional lazy-load
  config = function()
    local ok_ls, luasnip = pcall(require, "luasnip")
    if not ok_ls then
      return
    end

    -- VSCode-style community + your JSON
    local ok_vsc, vsc = pcall(require, "luasnip.loaders.from_vscode")
    if ok_vsc then
      vsc.lazy_load()
      vsc.lazy_load({ paths = "~/.config/nvim/snippets" })
    end

    -- 🔴 This is what loads bd808:
    local ok_lua, lua_loader = pcall(require, "luasnip.loaders.from_lua")
    if ok_lua then
      lua_loader.load({ paths = "~/.config/nvim/lua/snippets" })
      -- Or restrict to the filetype if you prefer:
      -- lua_loader.load({ paths = "~/.config/nvim/lua/snippets", include = { "supercollider" } })
    end

    -- SCNvim-generated snippets
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
