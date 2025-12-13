return {
  {
    "folke/snacks.nvim",
    -- you can keep other opts you already have here
    opts = {
      -- optional: leave terminal style mostly default
      styles = {
        terminal = {
          -- remove / don't set position here if you want per-key control
          -- position = "bottom",
        },
      },
    },
    keys = function(_, keys)
      local LazyVim = require("lazyvim.util")

      -- bottom / horizontal split
      table.insert(keys, {
        "<leader>ft",
        function()
          Snacks.terminal(nil, {
            cwd = LazyVim.root(),
            win = {
              position = "bottom", -- horizontal
              split = "below",     -- regular split, not float
              height = 0.2,        -- 30% of editor height
            },
          })
        end,
        desc = "Terminal (root, bottom)",
      })

      -- right / vertical split
      table.insert(keys, {
        "<leader>fT",
        function()
          Snacks.terminal(nil, {
            cwd = LazyVim.root(),
            win = {
              position = "right", -- vertical
              split = "right",
              width = 0.25,        -- 40% of editor width
            },
          })
        end,
        desc = "Terminal (root, right)",
      })

      return keys
    end,
  },
}

