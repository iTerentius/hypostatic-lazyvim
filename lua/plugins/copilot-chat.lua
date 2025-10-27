return {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "main",
  cmd = { "CopilotChat" }, -- allows lazy-loading on :CopilotChat
  opts = function()
    local user = vim.env.USER or "User"
    -- Proper Lua concatenation:
    user = user:sub(1, 1):upper() .. user:sub(2)
    return {
      auto_insert_mode = true,
      question_header = "  " .. user .. " ",
      answer_header = "  Copilot ",
      window = {
        width = 0.4,
      },
      context = "project",
    }
  end,

  -- These keys will trigger lazy-loading and then call the module
  keys = {
    { "<leader>a", "", desc = "+ai" },

    {
      "<leader>aa",
      function()
        require("CopilotChat").toggle()
      end,
      desc = "Toggle (CopilotChat)",
      mode = { "n", "v" },
    },
    {
      "<leader>ax",
      function()
        require("CopilotChat").reset()
      end,
      desc = "Clear (CopilotChat)",
      mode = { "n", "v" },
    },
    {
      "<leader>aq",
      function()
        vim.ui.input({ prompt = "Quick Chat: " }, function(input)
          if input and input ~= "" then
            require("CopilotChat").ask(input)
          end
        end)
      end,
      desc = "Quick Chat (CopilotChat)",
      mode = { "n", "v" },
    },
    {
      "<leader>ap",
      function()
        require("CopilotChat").select_prompt()
      end,
      desc = "Prompt Actions (CopilotChat)",
      mode = { "n", "v" },
    },
  },

  config = function(_, opts)
    local chat = require("CopilotChat")
    chat.setup(opts)

    
    -- Buffer-local tweaks & submit key inside the CopilotChat buffer
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "copilot-chat",
      callback = function(ev)
        -- cleaner chat buffer
        vim.opt_local.relativenumber = false
        vim.opt_local.number = false

        -- Submit the prompt with <C-s> while typing
        -- (the input takes <CR> as submit; we remap <C-s> -> <CR>)
        vim.keymap.set("i", "<C-s>", "<CR>", {
          buffer = ev.buf,
          remap = true,
          desc = "CopilotChat: Submit",
        })
      end,
    })
  end,
}
