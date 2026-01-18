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
            ["fetch"] = {
              opts = {
                adapter = "anthropic",
              },
            },
          },
          roles = {
            llm = "CodeCompanion",
            user = "Me",
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
            ["editor"] = {
              enabled = true,
            },
            ["rag"] = {
              enabled = true,
              opts = {
                -- Automatically index project on startup
                auto_index = true,
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
                  "lazy-lock.json",
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
                  "*.vim",
                  "*.sh",
                  "*.bash",
                  "*.zsh",
                  "Makefile",
                  "Dockerfile",
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
          return "You are an AI coding assistant with access to the entire project codebase. "
            .. "Working directory: " .. vim.fn.getcwd() .. "\n"
            .. "You can use the RAG tool to search and reference any files in the project."
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
        diff = {
          provider = "mini_diff",
        },
      },
    })

    -- Auto-index project on VimEnter for immediate access
    vim.api.nvim_create_autocmd("VimEnter", {
      pattern = "*",
      callback = function()
        -- Delay indexing slightly to not block startup
        vim.defer_fn(function()
          -- Only index if we're in a git repository (project directory)
          if vim.fn.isdirectory(".git") == 1 then
            vim.notify("CodeCompanion: Indexing project...", vim.log.levels.INFO)
            -- Trigger RAG indexing
            pcall(function()
              require("codecompanion").index()
            end)
          end
        end, 1000) -- Wait 1 second after startup
      end,
    })
  end,
  keys = {
    -- Toggle chat window
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI: Toggle Chat", mode = { "n", "v" } },

    -- Open chat with selected code
    { "<leader>aa", "<cmd>CodeCompanionChat Add<cr>", desc = "AI: Add to Chat", mode = "v" },

    -- Inline assistant
    { "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "AI: Inline Assistant", mode = { "n", "v" } },

    -- Quick actions (changed from <leader>ae to avoid conflict with Avante)
    { "<leader>ax", "<cmd>CodeCompanionActions<cr>", desc = "AI: Actions", mode = { "n", "v" } },

    -- Chat with buffer context
    { "<leader>ab", function()
      vim.cmd("CodeCompanionChat")
      vim.defer_fn(function()
        vim.cmd("startinsert")
        vim.api.nvim_feedkeys("/buffer\n", "n", false)
      end, 150)
    end, desc = "AI: Chat with Buffer", mode = "n" },

    -- Chat with file picker
    { "<leader>af", function()
      vim.cmd("CodeCompanionChat")
      vim.defer_fn(function()
        vim.cmd("startinsert")
        vim.api.nvim_feedkeys("/file\n", "n", false)
      end, 150)
    end, desc = "AI: Chat with File", mode = "n" },

    -- Chat with symbols (project context) (changed from <leader>ar to avoid conflict with Avante)
    { "<leader>ag", function()
      vim.cmd("CodeCompanionChat")
      vim.defer_fn(function()
        vim.cmd("startinsert")
        vim.api.nvim_feedkeys("/symbols\n", "n", false)
      end, 150)
    end, desc = "AI: Chat with Symbols", mode = "n" },

    -- Manually trigger project indexing
    { "<leader>aI", function()
      vim.notify("CodeCompanion: Indexing project...", vim.log.levels.INFO)
      pcall(function()
        require("codecompanion").index()
      end)
    end, desc = "AI: Index Project", mode = "n" },
  },
}
