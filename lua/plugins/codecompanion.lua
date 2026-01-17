return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- Optional: for file selection
    "stevearc/dressing.nvim", -- Optional: improves UI
  },
  cmd = {
    "CodeCompanion",
    "CodeCompanionChat",
    "CodeCompanionActions",
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "ANTHROPIC_API_KEY"
            },
            schema = {
              model = {
                default = "claude-sonnet-4-20250514",
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "anthropic",
          slash_commands = {
            ["buffer"] = {
              opts = {
                contains_code = true,
              },
            },
            ["file"] = {
              opts = {
                contains_code = true,
              },
            },
            ["telescope"] = {
              opts = {
                contains_code = true,
              },
            },
          },
        },
        inline = {
          adapter = "anthropic",
        },
        agent = {
          adapter = "anthropic",
          tools = {
            ["cmd_runner"] = {
              enabled = true,
            },
            ["rag"] = {
              enabled = true,
              opts = {
                -- File patterns to exclude from indexing
                exclude_patterns = {
                  "node_modules",
                  ".git",
                  "*.lock",
                  "package-lock.json",
                  "yarn.lock",
                  "pnpm-lock.yaml",
                  ".DS_Store",
                  "dist",
                  "build",
                  "target",
                  ".next",
                  ".nuxt",
                  "coverage",
                  "*.min.js",
                  "*.min.css",
                  "*.map",
                  ".env*",
                  "*.log",
                },
                -- Only index these file types
                include_patterns = {
                  "*.lua",
                  "*.py",
                  "*.js",
                  "*.ts",
                  "*.jsx",
                  "*.tsx",
                  "*.go",
                  "*.rs",
                  "*.java",
                  "*.c",
                  "*.cpp",
                  "*.h",
                  "*.hpp",
                  "*.md",
                  "*.txt",
                  "*.json",
                  "*.yaml",
                  "*.yml",
                  "*.toml",
                },
              },
            },
          },
        },
      },
      opts = {
        -- Enable automatic project context
        send_code = true,
        use_default_actions = true,
        -- Custom system prompt with working directory
        system_prompt = function(opts)
          return "You have access to the project files in: " .. vim.fn.getcwd()
        end,
      },
      display = {
        chat = {
          window = {
            layout = "vertical",
            width = 0.45,
            height = 0.8,
          },
          show_settings = true,
          show_token_count = true,
        },
      },
    })
  end,
  keys = {
    -- Toggle chat window
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI: Toggle Chat", mode = { "n", "v" } },
    
    -- Open chat with selected code
    { "<leader>aa", "<cmd>CodeCompanionChat Add<cr>", desc = "AI: Add to Chat", mode = "v" },
    
    -- Inline assistant
    { "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "AI: Inline Assistant", mode = { "n", "v" } },
    
    -- Quick actions
    { "<leader>ae", "<cmd>CodeCompanionActions<cr>", desc = "AI: Actions", mode = { "n", "v" } },
    
    -- Chat with buffer context
    { "<leader>ab", function()
      vim.cmd("CodeCompanionChat")
      vim.api.nvim_feedkeys("/buffer\n", "n", false)
    end, desc = "AI: Chat with Buffer", mode = "n" },
    
    -- Chat with file picker
    { "<leader>af", function()
      vim.cmd("CodeCompanionChat")
      vim.api.nvim_feedkeys("/file\n", "n", false)
    end, desc = "AI: Chat with File", mode = "n" },
    
    -- Chat with RAG (project context)
    { "<leader>ar", function()
      vim.cmd("CodeCompanionChat")
      vim.api.nvim_feedkeys("/rag\n", "n", false)
    end, desc = "AI: Chat with RAG", mode = "n" },
  },
}
