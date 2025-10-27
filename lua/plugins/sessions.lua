return {
  -- disable LazyVim's default one-session-per-dir plugin
  { "folke/persistence.nvim", enabled = false },

  {
    "olimorris/persisted.nvim",
    event = "VimEnter", -- or lazy=false
    config = function()
      require("persisted").setup({
        save_dir = vim.fn.stdpath("state") .. "/sessions",
        use_git_branch = true,   -- optional: separate by branch
        autoload = false,        -- pick sessions explicitly
        silent = true,
        telescope = {
          reset_prompt_after_deletion = true,
        },
        should_save = function()
          local skip = { gitcommit = true, gitrebase = true }
          return not skip[vim.bo.filetype]
        end,
      })

      -- load Telescope extension safely
      local ok, telescope = pcall(require, "telescope")
      if ok and telescope.load_extension then
        pcall(telescope.load_extension, "persisted")
      end

      -- keymaps
      local persisted = require("persisted")
      vim.keymap.set("n", "<leader>Qs", function() persisted.save() end, { desc = "Session: Save (named)" })
      vim.keymap.set("n", "<leader>Ql", "<cmd>Telescope persisted<cr>", { desc = "Session: List/Load" })
      vim.keymap.set("n", "<leader>Qd", function() persisted.delete() end, { desc = "Session: Delete current" })
      vim.keymap.set("n", "<leader>Q.", function() persisted.stop() end, { desc = "Session: Toggle autosave" })
    end,
    dependencies = { "nvim-telescope/telescope.nvim" }, -- LazyVim already has this, but harmless to declare
  },
}
