
return {
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "folke/trouble.nvim",
    },
    opts = {
      api_key_cmd = "bash -lc 'echo $OPENAI_API_KEY'",
      openai_params = { model = "gpt-4o-mini" },
    },
    config = function(_, opts)
      require("chatgpt").setup(opts)

      -- Helpers: send buffer/selection to ChatGPT
      local M = {}

      function M.buf_text(bufnr)
        bufnr = bufnr or 0
        return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
      end

      function M.ask_about_buffer(bufnr, question)
        bufnr = bufnr or 0
        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
        local body = M.buf_text(bufnr)
        local prompt = ("Here is file `%s`:\n\n%s\n\nQuestion: %s")
          :format(name == "" and "[No Name]" or name, body, question or "Explain this file and suggest improvements.")
        require("chatgpt").ask(prompt)
      end

      function M.edit_with_instructions_for_selection_or_buffer()
        -- If there is a visual selection, ChatGPT.nvim will use it; otherwise it uses the whole buffer.
        vim.cmd("ChatGPTEditWithInstructions")
      end

      -- Telescope picker: choose a buffer, then ask
      function M.ask_via_picker()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        local bufs = {}
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_option(b, "buflisted") then
            local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":.")
            table.insert(bufs, { bufnr = b, name = (name == "" and "[No Name]" or name) })
          end
        end

        pickers
          .new({}, {
            prompt_title = "ChatGPT: Ask About Buffer",
            finder = finders.new_table({
              results = bufs,
              entry_maker = function(e)
                return {
                  value = e,
                  display = e.name,
                  ordinal = e.name,
                }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
              local function confirm()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                vim.ui.input({ prompt = "Question: " }, function(q)
                  M.ask_about_buffer(selection.value.bufnr, q)
                end)
              end
              map("i", "<CR>", confirm)
              map("n", "<CR>", confirm)
              return true
            end,
          })
          :find()
      end

      -- Keymaps
      local map = vim.keymap.set
      -- Chat window
      map("n", "<leader>cc", "<cmd>ChatGPT<cr>", { desc = "ChatGPT: Open Chat" })
      -- Edit (selection → doc; none → whole buffer)
      map({ "n", "v" }, "<leader>ce", M.edit_with_instructions_for_selection_or_buffer, { desc = "ChatGPT: Edit With Instructions" })
      -- Ask about current buffer (prompts for a question)
      map("n", "<leader>cb", function()
        vim.ui.input({ prompt = "Question: " }, function(q) M.ask_about_buffer(0, q) end)
      end, { desc = "ChatGPT: Ask About Current Buffer" })
      -- Ask via Telescope picker (choose any open buffer)
      map("n", "<leader>cB", M.ask_via_picker, { desc = "ChatGPT: Ask About Chosen Buffer (Telescope)" })
    end,
  },
}
