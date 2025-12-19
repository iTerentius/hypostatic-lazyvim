return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, 
  opts = {
    -- 1. Main Provider Selection
    provider = "copilot",
    
    -- 2. CORRECTED CONFIGURATION STRUCTURE
    -- Instead of `gemini = { ... }`, we now nest it under `providers`
    providers = {
      gemini = {
        -- The new standard as of Dec 2025
        model = "gemini-2.5-flash", 
        -- If that fails (due to regional rollout), try "gemini-3-flash-preview"
        -- or the powerful "gemini-3-pro" for complex architecture questions.
        
        temperature = 0,
        max_tokens = 8192, -- Gemini 3 allows larger output tokens
      },
      copilot = {
        model = "gpt-4o-2024-08-06", -- or "claude-3.5-sonnet" if you have it enabled in GitHub settings
        max_tokens = 4096,
        temperature = 0,
      },
    },
        -- 3. KEYMAPPINGS (Kept conflict-free for you)
    provider = "gemini",
    
    -- 2. PROVIDERS CONFIG
    providers = {
      gemini = {
        model = "gemini-2.5-flash", 
        temperature = 0,
        max_tokens = 8192,
      },
      copilot = {
        model = "gpt-4o-2024-08-06",
        extra_request_body = {
          temperature = 0,
          max_tokens = 4096,
        }
      },
    },

    -- 3. KEYMAPPINGS
    mappings = {
      ask = "<leader>av",     -- Avante Chat
      edit = "<leader>ae",    -- Avante Edit
      refresh = "<leader>ar", -- Avante Refresh
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
    },

    behaviour = {
      auto_suggestions = false, -- Disable ghost text (since you use Copilot for this)
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = true,
    },
    
    windows = {
      position = "right",
      width = 30,
      sidebar_header = {
        align = "center",
        rounded = true,
      },
    },
  },
  
  build = "make",
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "hrsh7th/nvim-cmp",
    "zbirenbaum/copilot.lua",
    "nvim-tree/nvim-web-devicons",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = { file_types = { "markdown", "Avante" } },
      ft = { "markdown", "Avante" },
    },
  },
}
