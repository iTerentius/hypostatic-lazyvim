-- ~/.config/nvim/lua/plugins/cmp-scnvim.lua
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "quangnguyen30192/cmp-nvim-tags",
    "saadparwaiz1/cmp_luasnip",
  },
  opts = function(_, opts)
    opts.sources = opts.sources or {}

    -- add source only if missing
    local function ensure_source(name)
      for _, s in ipairs(opts.sources) do
        if s.name == name then
          return
        end
      end
      table.insert(opts.sources, { name = name })
    end
    ensure_source("tags")
    ensure_source("luasnip")

    -- make sure SCNvim's tags file is searched
    local candidates = vim.api.nvim_get_runtime_file("scnvim-data/tags", true)
    if #candidates == 0 then
      candidates = { vim.fn.stdpath("data") .. "/scnvim/tags" }
    end
    for _, f in ipairs(candidates) do
      local uv = vim.uv or vim.loop
      if uv.fs_stat(f) then
        local current = table.concat(vim.opt.tags:get(), ",")
        if not current:find(vim.pesc(f), 1, true) then
          vim.opt.tags:append(f)
        end
      end
    end
  end,
}
