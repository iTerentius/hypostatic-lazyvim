return {
  -- SCNvim itself
  {
    "davidgranstrom/scnvim",
    ft = { "supercollider" }, -- load only for .sc / .scd
    config = function()
      local scnvim = require("scnvim")
      local map = scnvim.map
      local map_expr = scnvim.map_expr

      scnvim.setup({
        -- your helpful defaults
        snippet = {
          engine = { name = "luasnip", options = { descriptions = true } },
        },
        editor = {
          signature = { auto = true, float = true },
          highlight = { color = "IncSearch" },
          -- forces correct ft for *.sc to avoid Scala
          force_ft_supercollider = true,
        },
        -- post window & eval flash: mirrors your old vim.g settings
        postwin = {
          float = { enabled = false },
          highlight = true, -- scnvim_postwin_syntax_hl = 1
          horizontal = false, -- 'v' => vertical split (false)
          direction = "right",
          size = 50,
          auto_toggle_error = true,
        },
        documentation = {
          -- If pandoc exists here, keep it; if not, remove this `cmd` line and
          -- scnvim will use SuperCollider’s HelpBrowser instead.
          cmd = "/opt/homebrew/bin/pandoc",
          horizontal = true,
          direction = "top",
        },
        eval = {
          flash = { duration = 100, repeats = 2 },
        },
        keymaps = {
          ["<M-e>"] = map("editor.send_line", { "i", "n" }),
          ["<C-e>"] = {
            map("editor.send_block", { "i", "n" }),
            map("editor.send_selection", "x"),
          },
          ["<CR>"] = map("postwin.toggle"),
          ["<M-CR>"] = map("postwin.toggle", "i"),
          ["<M-L>"] = map("postwin.clear", { "n", "i" }),
          ["<C-k>"] = map("signature.show", { "n", "i" }),
          ["<F12>"] = map("sclang.hard_stop", { "n", "x", "i" }),
          ["<leader>st"] = map("sclang.start"),
          ["<leader>sk"] = map("sclang.recompile"),
          ["<F1>"] = map_expr("s.boot"),
          ["<F2>"] = map_expr("s.meter"),
        },
      })

      -- Kill any existing "K" in this buffer, then map SCDoc.
      local function set_sc_doc_key(buf)
        pcall(vim.keymap.del, "n", "K", { buffer = buf })
        vim.keymap.set("n", "K", function()
          require("scnvim.help").open_help_for(vim.fn.expand("<cword>"))
        end, { buffer = buf, desc = "SC: Help for symbol", silent = true })
      end

      -- When you enter a SuperCollider buffer, enforce our K mapping.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "supercollider",
        callback = function(args)
          -- slight defer to win the race against other mappers
          vim.defer_fn(function()
            set_sc_doc_key(args.buf)
          end, 10)
        end,
      })

      -- If *anything* attaches an LSP later, re-enforce our K in SC buffers.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          if vim.bo[args.buf].filetype == "supercollider" then
            vim.defer_fn(function()
              set_sc_doc_key(args.buf)
            end, 10)
          end
        end,
      })
    end,
  },

  -- 2) lualine: add SC server status in X section when in supercollider files
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local function sc_status()
        local ok, st = pcall(require, "scnvim.statusline")
        if not ok then
          return "" -- scnvim not loaded yet (non-SC buffers)
        end
        return st.get_server_status() or ""
      end
      -- show only in SC buffers so it doesn’t clutter other filetypes
      table.insert(opts.sections.lualine_x, 1, {
        sc_status,
        cond = function()
          return vim.bo.filetype == "supercollider"
        end,
      })
    end,
    -- (optional) ensure lualine sees scnvim if both load together
    dependencies = { "davidgranstrom/scnvim" },
  },

  -- 3) completion for SC: add tags source + snippets
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "quangnguyen30192/cmp-nvim-tags", -- completion from Vim "tags"
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    opts = function(_, opts)
      -- ensure 'tags' source exists (keep your other sources intact)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "tags" })
      table.insert(opts.sources, { name = "luasnip" })

      -- Make sure the SC tags file produced by :SCNvimGenerateAssets is searched.
      -- Try to find the plugin-provided location first, otherwise fall back to stdpath.
      local rt = vim.api.nvim_get_runtime_file("scnvim-data/tags", false)
      local sc_tags = (rt and rt[1]) or (vim.fn.stdpath("data") .. "/scnvim/tags")
      if sc_tags and vim.loop.fs_stat(sc_tags) then
        vim.opt.tags:append(sc_tags)
      end
    end,
  },
}
