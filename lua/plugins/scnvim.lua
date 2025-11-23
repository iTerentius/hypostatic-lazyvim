-- lua/plugins/scnvim.lua
-- 2025-11-22 full patched version: SC buffer-local <Tab> expands LuaSnip snippets

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
          float = { enabled = false }, -- split mode
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

        -- keymaps
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

      -------------------------------------------------------------------
      -- post window styling and custom word highlights
      -------------------------------------------------------------------
      do
        local set_hl = vim.api.nvim_set_hl

        -- highlight groups
        set_hl(0, "SCPostNormal", { link = "Normal" })
        set_hl(0, "SCPostWinSep", { link = "WinSeparator" })
        set_hl(0, "SCPostSuccess", { link = "DiagnosticOk", bold = true })
        set_hl(0, "SCPostWarn", { link = "DiagnosticWarn", bold = true })
        set_hl(0, "SCPostError", { link = "DiagnosticError", bold = true })
        set_hl(0, "SCPostNote", { link = "Title", italic = true, bold = true })

        -- detect post buffer
        local function is_postbuf(buf)
          if not vim.api.nvim_buf_is_valid(buf) then
            return false
          end
          local ft = vim.bo[buf].filetype
          if ft == "scnvim_postwin" or ft == "supercollider.post" then
            return true
          end
          local name = vim.api.nvim_buf_get_name(buf)
          return name:match("SCNvim Post") ~= nil
        end

        -- style post window
        vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
          callback = function(args)
            local buf = args.buf
            local win = vim.api.nvim_get_current_win()
            if not is_postbuf(buf) then
              return
            end
            vim.wo[win].winhl = table.concat({
              "Normal:SCPostNormal",
              "NormalNC:SCPostNormal",
              "WinSeparator:SCPostWinSep",
              "EndOfBuffer:NonText",
            }, ",")
            vim.wo[win].wrap = true
          end,
        })

        -- keywords
        local WORDS = {
          { pattern = [[\<OK\>\|\<SUCCESS\>\|\<booted\>]], group = "SCPostSuccess", prio = 15 },
          { pattern = [[\<WARN\>\|\<WARNING\>\|\<Deprecation\>]], group = "SCPostWarn", prio = 15 },
          { pattern = [[\<ERROR\>\|\<FAIL\>\|\<DoesNotUnderstand\>]], group = "SCPostError", prio = 15 },
          { pattern = [[\<s.boot\>\|\<s.meter\>\|\<scsynth\>]], group = "SCPostNote", prio = 10 },
          { pattern = [[\<cc\>]], group = "SCPostNote", prio = 10 },
        }

        local function add_matches(win, buf)
          if not is_postbuf(buf) then
            return
          end
          vim.w[win].scpost_match_ids = {}
          for _, w in ipairs(WORDS) do
            local id = vim.fn.matchadd(w.group, w.pattern, w.prio or 10)
            table.insert(vim.w[win].scpost_match_ids, id)
          end
        end

        local function clear_matches(win)
          if not vim.w[win].scpost_match_ids then
            return
          end
          for _, id in ipairs(vim.w[win].scpost_match_ids) do
            pcall(vim.fn.matchdelete, id)
          end
          vim.w[win].scpost_match_ids = nil
        end

        vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
          callback = function(args)
            local buf = args.buf
            local win = vim.api.nvim_get_current_win()
            if is_postbuf(buf) then
              clear_matches(win)
              add_matches(win, buf)
            end
          end,
        })

        vim.api.nvim_create_autocmd({ "WinClosed", "BufWipeout" }, {
          callback = function(args)
            local win = tonumber(args.match) or 0
            if win ~= 0 then
              clear_matches(win)
            end
          end,
        })

        vim.api.nvim_create_user_command("SCPostHi", function(opts)
          local word = vim.fn.escape(opts.fargs[1] or "", [[\]])
          local group = opts.fargs[2] or "SCPostNote"
          local pat = ([[\<%s\>]]):format(word)
          local win = vim.api.nvim_get_current_win()
          vim.fn.matchadd(group, pat, 12)
        end, { nargs = "+" })
      end

      -----------------------------------------------------------------
      -- floating SCDoc override
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

          local path = uri:gsub("^file://", "")
          path = vim.fn.fnamemodify(path, ":p")
          local ok_read, lines = pcall(vim.fn.readfile, path)
          if not ok_read then
            vim.notify("scnvim: failed to read help file: " .. tostring(lines), vim.log.levels.ERROR)
            return
          end

          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.bo[buf].bufhidden = "wipe"
          vim.bo[buf].buftype = "nofile"
          vim.bo[buf].swapfile = false
          vim.bo[buf].modifiable = false
          vim.bo[buf].filetype = "help"

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

          if pattern and #pattern > 0 then
            for i, l in ipairs(lines) do
              if l:find(pattern, 1, true) then
                pcall(vim.api.nvim_win_set_cursor, win, { i, 0 })
                break
              end
            end
          end

          vim.keymap.set({ "n", "i" }, "q", function()
            pcall(vim.api.nvim_win_close, win, true)
          end, { buffer = buf, nowait = true, silent = true })
        end)
      end

      -----------------------------------------------------------------
      -- buffer bootstrap: tags, doc keymaps, comma grid, align maps
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

          -- completion popup for blink.cmp
          vim.keymap.set("i", "<C-M-Space>", function()
            local ok_b, blink = pcall(require, "blink.cmp")
            if ok_b then
              blink.show()
            end
          end, { buffer = buf, desc = "Completion: show menu" })

          -- neutralize Ctrl-Space variants
          for _, lhs in ipairs({ "<C-Space>", "<C-@>" }) do
            pcall(vim.keymap.del, "i", lhs, { buffer = buf })
            pcall(vim.keymap.del, "n", lhs, { buffer = buf })
            pcall(vim.keymap.del, "v", lhs, { buffer = buf })
            pcall(vim.keymap.del, "s", lhs, { buffer = buf })
            vim.keymap.set({ "n", "i", "v", "s" }, lhs, "<Nop>", { buffer = buf, silent = true })
          end

          -- insert comma + Tab for pattern grid alignment
          vim.keymap.set("i", ",", ",\t", { buffer = buf, noremap = true, silent = true })

          -- align lists on commas (requires Tabularize plugin)
          vim.keymap.set(
            "n",
            "<leader>a,",
            ":.Tabularize /,\\zs<CR>",
            { buffer = buf, noremap = true, silent = true, desc = "Align SC list by comma (line)" }
          )
          vim.keymap.set(
            "v",
            "<leader>a,",
            ":Tabularize /,\\zs<CR>",
            { buffer = buf, noremap = true, silent = true, desc = "Align SC list by comma (selection)" }
          )

          set_sc_doc_key(buf)
          set_sc_doc_prompt_key(buf)

          -- 2025-11-22 force LuaSnip expansion on Tab in SC buffers
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
  -- lualine: show scsynth status when editing SC files
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
  -- Blink + compat + tags provider
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

      opts.completion = vim.tbl_deep_extend("force", opts.completion or {}, {
        trigger = { show_on_keyword = true, show_on_trigger_character = true },
        menu = { auto_show = true },
        list = { selection = { preselect = false, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
      })

      -- 2025-11-22: tell blink to use LuaSnip (NOT vim.snippet)
      opts.snippets = { preset = "luasnip" }

      -- Super-tab: snippet expand/jump → completion nav → fallback
      -- Keymaps: blink must NOT own <Tab>; SC ftplugin handles snippets/navigation
      opts.keymap = { preset = "none" }
      opts.keymap["<C-space>"] = false
      opts.keymap["<C-M-Space>"] = { "show" }
      opts.keymap["<C-l>"] = { "show" }

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

      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      opts.sources.per_filetype.supercollider = { "tags", "snippets", "buffer", "path" }

      -- Ensure SC filetype uses sources in the correct order
      opts.sources = opts.sources or {}
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      opts.sources.per_filetype.supercollider = {
        "tags",
        "snippets",
        "buffer",
        "path",
      }

      return opts
    end,
  },
}