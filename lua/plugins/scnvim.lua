-- lua/plugins/scnvim.lua
return {
  -------------------------------------------------------------------
  -- 1) SuperCollider frontend
  -------------------------------------------------------------------
  {
    "davidgranstrom/scnvim",
    ft = "supercollider",
    config = function()
      -- locals first
      local scnvim = require("scnvim")
      local map = scnvim.map
      local map_expr = scnvim.map_expr

      scnvim.setup({
        snippet = { engine = { name = "luasnip", options = { descriptions = true } } },
        editor = {
          signature = { auto = true, float = true },
          highlight = { color = "IncSearch" },
          force_ft_supercollider = true,
        },
        postwin = {
          float = { enabled = false },
          highlight = true,
          horizontal = false,
          direction = "right",
          size = 50,
          auto_toggle_error = true,
        },
        -- Let scnvim render docs via pandoc (keeps content inside Neovim)
        documentation = {
          -- Remove or change this path if pandoc lives elsewhere
          cmd = "/opt/homebrew/bin/pandoc",
        },
        eval = { flash = { duration = 100, repeats = 2 } },

        -- === KEYMAPS (from your last working file) ===
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

      -----------------------------------------------------------------
      -- Floating-window SCDoc override (robust, no syntax tricks)
      -----------------------------------------------------------------
      local ok_help, help = pcall(require, "scnvim.help")
      if ok_help and help and help.on_open and type(help.on_open.replace) == "function" then
        help.on_open:replace(function(err, uri, pattern)
          if err then
            vim.notify("scnvim help error: " .. tostring(err), vim.log.levels.ERROR)
            return
          end
          if not uri or #uri == 0 then
            vim.notify("scnvim: no help URI provided", vim.log.levels.WARN)
            return
          end

          -- Normalize file:// URI to a path and read the rendered text
          local path = uri:gsub("^file://", "")
          path = vim.fn.fnamemodify(path, ":p")
          local ok_read, lines = pcall(vim.fn.readfile, path)
          if not ok_read then
            vim.notify("scnvim: failed to read help file: " .. tostring(lines), vim.log.levels.ERROR)
            return
          end

          -- Create scratch buffer and open centered float
          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.bo[buf].bufhidden = "wipe"
          vim.bo[buf].buftype = "nofile"
          vim.bo[buf].swapfile = false
          vim.bo[buf].modifiable = false
          vim.bo[buf].filetype = "help" -- or "markdown"

          local width = math.floor(vim.o.columns * 0.6)
          local height = math.floor(vim.o.lines * 0.7)
          local row = math.max(math.floor((vim.o.lines - height) / 2 - 1), 1)
          local col = math.max(math.floor((vim.o.columns - width) / 2), 1)
          local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            border = "rounded",
            style = "minimal",
            noautocmd = true,
          })
          vim.wo[win].wrap = true

          -- Jump to first matching line, if any
          if pattern and #pattern > 0 then
            for i, l in ipairs(lines) do
              if l:find(pattern, 1, true) then
                pcall(vim.api.nvim_win_set_cursor, win, { i, 0 })
                break
              end
            end
          end

          -- Quick close (q)
          vim.keymap.set({ "n", "i" }, "q", function()
            pcall(vim.api.nvim_win_close, win, true)
          end, { buffer = buf, nowait = true, silent = true })
        end)
      end

      -----------------------------------------------------------------
      -- Buffer bootstrap: tags wiring, K mapping, manual popup key
      -----------------------------------------------------------------
      local function set_sc_doc_key(buf)
        pcall(vim.keymap.del, "n", "K", { buffer = buf })
        vim.keymap.set("n", "K", function()
          require("scnvim.help").open_help_for(vim.fn.expand("<cword>"))
        end, { buffer = buf, desc = "SC: Help for symbol", silent = true })
      end

      local function set_sc_doc_prompt_key(buf)
        pcall(vim.keymap.del, "n", "<leader>sh", { buffer = buf })
        vim.keymap.set("n", "<leader>sh", function()
          vim.ui.input({ prompt = "SCDoc topic: " }, function(input)
            if input and #input > 0 then
              local ok_h, h = pcall(require, "scnvim.help")
              if ok_h and h and h.open_help_for then
                h.open_help_for(input)
              else
                vim.cmd("SCNvimHelp " .. input)
              end
            end
          end)
        end, { buffer = buf, desc = "SC: Search SuperCollider help" })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "supercollider",
        callback = function(args)
          local buf = args.buf
          local sc_tags = vim.fn.stdpath("cache") .. "/scnvim/tags"
          if vim.fn.filereadable(sc_tags) == 0 then
            vim.notify("scnvim: generating assets (tags/snippets)…")
            vim.cmd("SCNvimGenerateAssets")
          end
          if vim.fn.filereadable(sc_tags) == 1 then
            vim.opt_local.tags:append(sc_tags)
          end
          vim.bo[buf].tagfunc = nil

          -- Manual completion popup for blink.cmp
          vim.keymap.set("i", "<C-M-Space>", function()
            local ok_b, blink = pcall(require, "blink.cmp")
            if ok_b then
              blink.show()
            end
          end, { buffer = buf, desc = "Completion: show menu" })

          -- Neutralize <C-Space>/<C-@> in SC buffers (often enter Visual)
          for _, lhs in ipairs({ "<C-Space>", "<C-@>" }) do
            pcall(vim.keymap.del, "i", lhs, { buffer = buf })
            pcall(vim.keymap.del, "n", lhs, { buffer = buf })
            pcall(vim.keymap.del, "v", lhs, { buffer = buf })
            pcall(vim.keymap.del, "s", lhs, { buffer = buf })
            vim.keymap.set({ "n", "i", "v", "s" }, lhs, "<Nop>", { buffer = buf, silent = true })
          end

          set_sc_doc_key(buf)
          set_sc_doc_prompt_key(buf)
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          if vim.bo[args.buf].filetype == "supercollider" then
            vim.defer_fn(function()
              set_sc_doc_key(args.buf)
              set_sc_doc_prompt_key(args.buf)
            end, 10)
          end
        end,
      })
    end,
  },

  -------------------------------------------------------------------
  -- 2) lualine: show scsynth status when editing SC files
  -------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local function sc_status()
        local ok, st = pcall(require, "scnvim.statusline")
        return ok and (st.get_server_status() or "") or ""
      end
      table.insert(opts.sections.lualine_x, 1, {
        sc_status,
        cond = function()
          return vim.bo.filetype == "supercollider"
        end,
      })
    end,
    dependencies = { "davidgranstrom/scnvim" },
  },

  -------------------------------------------------------------------
  -- 3) Blink + compat + tags provider
  -------------------------------------------------------------------
  { "saghen/blink.compat", version = "2.*", opts = {} },
  { "quangnguyen30192/cmp-nvim-tags", ft = "supercollider" },
  {
    "saghen/blink.cmp",
    dependencies = {
      { "saghen/blink.compat", opts = {} },
      "quangnguyen30192/cmp-nvim-tags",
    },
    opts = function(_, opts)
      opts = opts or {}

      -- Auto-show while typing and preview selection
      opts.completion = vim.tbl_deep_extend("force", opts.completion or {}, {
        trigger = { show_on_keyword = true, show_on_trigger_character = true },
        menu = { auto_show = true },
        list = { selection = { preselect = true, auto_insert = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
      })

      -- Keys: keep your Ctrl+Meta+Space, add Ctrl+L as a reliable fallback
      opts.keymap = opts.keymap or { preset = "enter" }
      opts.keymap["<C-space>"] = false
      opts.keymap["<C-M-Space>"] = { "show" }
      opts.keymap["<C-l>"] = { "show" }

      -- Enable the nvim-cmp “tags” source via blink.compat
      opts.sources = opts.sources or {}
      opts.sources.providers = vim.tbl_extend("force", opts.sources.providers or {}, {
        tags = {
          name = "tags",
          module = "blink.compat.source",
          min_keyword_length = 1,
          score_offset = 2,
        },
      })
      opts.sources.compat = vim.tbl_extend("force", opts.sources.compat or {}, { "tags" })

      -- Prefer these sources for SuperCollider (NO ctx function!)
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      opts.sources.per_filetype.supercollider = { "tags", "snippets", "buffer", "path" }

      return opts
    end,
  },
}
