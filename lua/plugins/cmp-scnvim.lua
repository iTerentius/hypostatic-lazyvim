-- ~/.config/nvim/lua/plugins/cmp-scnvim.lua
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "saadparwaiz1/cmp_luasnip",
    "quangnguyen30192/cmp-nvim-tags",
  },
  opts = function(_, opts)
  local cmp = require("cmp")

  -- preserve existing sources, then ensure ours
  opts.sources = opts.sources or {}

  local function ensure_source(entry)
    local name = type(entry) == "table" and entry.name or entry
    for _, s in ipairs(opts.sources) do
      if s.name == name then
        return
      end
    end
    table.insert(opts.sources, type(entry) == "table" and entry or { name = entry })
  end

  -- prefer LuaSnip in the top group; tags present but less noisy
  ensure_source({ name = "luasnip", group_index = 1, priority = 1000 })
  ensure_source({ name = "tags", group_index = 2, keyword_length = 3, priority = 250 })
  ensure_source({ name = "buffer", group_index = 2 })
  ensure_source({ name = "path", group_index = 2 })

  -- give snippets a little sorting boost
  opts.sorting = opts.sorting or {}
  opts.sorting.priority_weight = 2
  opts.sorting.comparators = opts.sorting.comparators
    or {
      cmp.config.compare.exact,
      function(a, b)
        -- prefer Snippet kind
        local K = cmp.lsp.CompletionItemKind
        local ak = a:get_kind() == K.Snippet and 1 or 0
        local bk = b:get_kind() == K.Snippet and 1 or 0
        if ak ~= bk then
          return ak > bk
        end
      end,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    }

  -- convenient mappings: Tab to expand/jump snippets; Shift-Tab to jump back
  opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
    ["<Tab>"] = cmp.mapping(function(fallback)
      local ls = require("luasnip")
      if cmp.visible() then
        cmp.select_next_item()
      elseif ls.expand_or_jumpable() then
        ls.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      local ls = require("luasnip")
      if cmp.visible() then
        cmp.select_prev_item()
      elseif ls.jumpable(-1) then
        ls.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-Space>"] = cmp.mapping.complete(),
  })

  -- filetype-specific sources for SuperCollider
  cmp.setup.filetype("supercollider", {
    sources = cmp.config.sources({
      { name = "luasnip", group_index = 1, priority = 1000 },
      { name = "tags", group_index = 2, keyword_length = 3, priority = 250 },
      { name = "buffer", group_index = 2 },
      { name = "path", group_index = 2 },
    }),
  })

  -- make "all" snippets available in supercollider too (optional)
  pcall(function()
    require("luasnip").filetype_extend("supercollider", { "all" })
  end)

  --------------------------------------------------------------------------
  -- Make sure SCNvim's tags file is searched (your original logic, kept)
  --------------------------------------------------------------------------
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
