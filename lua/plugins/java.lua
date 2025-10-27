-- File: ~/.config/nvim/lua/plugins/java.lua
-- Purpose: IntelliJ-like Java experience in LazyVim
-- Plugins + tooling + formatters + Treesitter

return {
  -- Core DAP (base plugin, no setup() call)
  { "mfussenegger/nvim-dap" },

  -- Java LSP / debug / tests
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {},
  },
  { "nvim-neotest/nvim-nio" },
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerBuild" },
    opts = {},
  },

  -- Ensure Treesitter has Java
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if type(opts.ensure_installed) == "table" then
        table.insert(opts.ensure_installed, "java")
      end
    end,
  },

  -- Install tools via Mason (now mason-org)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      local ensure = opts.ensure_installed
      local function add(x)
        if not vim.tbl_contains(ensure, x) then table.insert(ensure, x) end
      end
      add("jdtls")                 -- Eclipse JDT Language Server
      add("java-debug-adapter")    -- DAP: com.microsoft.java.debug
      add("java-test")             -- VSCode Java Test extensions
      add("google-java-format")    -- Formatter
      add("codelldb")              -- Handy DAP (native) fallback
      -- add("checkstyle")          -- Optional linter (Overseer task)
    end,
  },

  -- Use Conform for formatting with Google Java Format
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.java = { "google_java_format" }
      opts.format_on_save = opts.format_on_save or {}
      if opts.format_on_save.lsp_format == nil then
        opts.format_on_save.lsp_format = "fallback"
      end
    end,
  },

  -- Nice UI for diagnostics & code actions (optional, if not already)
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = { use_diagnostic_signs = true },
  },
}

