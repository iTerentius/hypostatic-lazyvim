-- LazyVim plugin spec: Tidal evaluation logger + runner
return {
  -- assumes you already use vim-tidal; if not, add "tidalcycles/vim-tidal" here
  {
    "tidalcycles/vim-tidal",
    config = function()
      ------------------------------------------------------------
      -- Config (tweakable without touching the rest)
      ------------------------------------------------------------
      -- one of: "single", "daily", "session", "project"
      vim.g.tidal_log_mode = vim.g.tidal_log_mode or "session"
      -- base directory for logs
      vim.g.tidal_log_dir = vim.g.tidal_log_dir or (vim.fn.expand("~/Music/tidal/_tidal-evals"))

      ------------------------------------------------------------
      -- Helpers
      ------------------------------------------------------------
      local M = {}

      local function ensure_dir(p)
        if vim.fn.isdirectory(p) == 0 then
          vim.fn.mkdir(p, "p")
        end
      end

      local function git_root()
        local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if vim.v.shell_error ~= 0 or not root or root == "" then
          return nil
        end
        return root
      end

      local session_id = os.date("!%Y%m%dT%H%M%SZ") -- UTC

      local function current_log_path()
        local basedir = vim.g.tidal_log_dir
        ensure_dir(basedir)

        local mode = vim.g.tidal_log_mode
        if mode == "single" then
          return basedir .. "/tidal-evals.log"
        elseif mode == "daily" then
          local d = os.date("!%Y-%m-%d")
          ensure_dir(basedir .. "/daily")
          return string.format("%s/daily/%s.log", basedir, d)
        elseif mode == "session" then
          ensure_dir(basedir .. "/sessions")
          return string.format("%s/sessions/%s.log", basedir, session_id)
        elseif mode == "project" then
          local root = git_root() or vim.fn.getcwd()
          local name = vim.fn.fnamemodify(root, ":t")
          ensure_dir(basedir .. "/projects/" .. name)
          local d = os.date("!%Y-%m-%d")
          return string.format("%s/projects/%s/%s-%s.log", basedir, name, d, session_id)
        else
          return basedir .. "/tidal-evals.log"
        end
      end

      local function get_visual_or_paragraph()
        local mode = vim.fn.mode()
        if mode:match("[vV\22]") then
          -- visual selection
          local _, ls, cs = unpack(vim.fn.getpos("'<"))
          local _, le, ce = unpack(vim.fn.getpos("'>"))
          local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)
          lines[1] = string.sub(lines[1], cs, -1)
          lines[#lines] = string.sub(lines[#lines], 1, ce)
          return lines, ls, le
        else
          -- paragraph around cursor (blank-line delimited)
          local row = vim.api.nvim_win_get_cursor(0)[1]
          local last = vim.api.nvim_buf_line_count(0)
          local function blank(l)
            return vim.fn.match(vim.fn.getline(l), "^%s*$") ~= -1
          end
          local s = row
          while s > 1 and not blank(s - 1) do
            s = s - 1
          end
          local e = row
          while e < last and not blank(e + 1) do
            e = e + 1
          end
          local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
          return lines, s, e
        end
      end

      local function append_log(lines)
        local path = current_log_path()
        local f = io.open(path, "a")
        if not f then
          vim.notify("tidal-logger: cannot open " .. path, vim.log.levels.ERROR)
          return
        end
        local ts = os.date("!%Y-%m-%dT%H:%M:%SZ")
        local file = vim.api.nvim_buf_get_name(0)
        f:write(string.rep("-", 60) .. "\n")
        f:write(string.format("-- %s | %s\n", ts, file))
        f:write(table.concat(lines, "\n"))
        f:write("\n")
        f:close()
        return path
      end

      function M.log_and_eval()
        local lines, s, e = get_visual_or_paragraph()
        local path = append_log(lines)
        if path then
          -- Evaluate via vim-tidal: same command your usual mappings call
          vim.cmd(("%d,%dTidalSend"):format(s, e))
          vim.notify("Tidal: logged + evaluated → " .. path, vim.log.levels.INFO, { title = "tidal-logger" })
        end
      end

      function M.open_log()
        local path = current_log_path()
        if vim.fn.filereadable(path) == 1 then
          vim.cmd.edit(path)
        else
          vim.notify(
            "No log yet for this mode. It will be created on first eval.",
            vim.log.levels.WARN,
            { title = "tidal-logger" }
          )
        end
      end

      function M.new_session()
        session_id = os.date("!%Y%m%dT%H%M%SZ")
        vim.notify("New Tidal log session: " .. session_id, vim.log.levels.INFO, { title = "tidal-logger" })
      end

      ------------------------------------------------------------
      -- Filetype autocmd + keymaps (Tidal buffers only)
      ------------------------------------------------------------
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tidal",
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true, noremap = true, desc = "" }
          opts.desc = "Log + Eval (visual selection or paragraph)"
          -- use <localleader>ee by default; change if you prefer
          vim.keymap.set({ "n", "v" }, "<localleader>ee", M.log_and_eval, opts)

          opts.desc = "Open current Tidal log"
          vim.keymap.set("n", "<localleader>el", M.open_log, opts)

          opts.desc = "Start a new log session"
          vim.keymap.set("n", "<localleader>en", M.new_session, opts)
        end,
      })
    end,
  },
}
