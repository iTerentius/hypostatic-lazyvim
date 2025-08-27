return {
  "tiagovla/tokyodark.nvim",
  opts = {
    -- custom options here
    transparent_background = true, -- set background to transparent
    gamma = 1.00, -- adjust the brightness of the theme
    styles = {
      comments = { italic = false }, -- style for comments
      keywords = { italic = false }, -- style for keywords
      identifiers = { italic = false }, -- style for identifiers
      functions = {}, -- style for functions
      variables = {}, -- style for variables
    },
    custom_highlights = {} or function(highlights, palette)
      return {}
    end, -- extend highlights
    custom_palette = {} or function(palette)
      return {}
    end, -- extend palette
    terminal_colors = true, -- enable terminal colors
  },
  config = function(_, opts)
    require("tokyodark").setup(opts) -- calling setup is optional
    vim.cmd([[colorscheme tokyodark]])
  end,
}
-- return {
--   "scottmckendry/cyberdream.nvim",
--   lazy = false,
--   priority = 1000,
-- }
-- lua/plugins/rose-pine.lua
-- return {
--   "rose-pine/neovim",
--   name = "rose-pine",
--   config = function()
--     vim.cmd("colorscheme rose-pine")
--   end,
-- }
-- return {
--   {
--     "catppuccin/nvim",
--     lazy = true,
--     name = "catppuccin",
--     opts = {
--       style = "mocha",
--       integrations = {
--         aerial = true,
--         alpha = true,
--         cmp = true,
--         dashboard = true,
--         flash = true,
--         fzf = true,
--         grug_far = true,
--         gitsigns = true,
--         headlines = true,
--         illuminate = true,
--         indent_blankline = { enabled = true },
--         leap = true,
--         lsp_trouble = true,
--         mason = true,
--         markdown = true,
--         mini = true,
--         native_lsp = {
--           enabled = true,
--           underlines = {
--             errors = { "undercurl" },
--             hints = { "undercurl" },
--             warnings = { "undercurl" },
--             information = { "undercurl" },
--           },
--         },
--         navic = { enabled = true, custom_bg = "lualine" },
--         neotest = true,
--         neotree = true,
--         noice = true,
--         notify = true,
--         semantic_tokens = true,
--         snacks = true,
--         telescope = true,
--         treesitter = true,
--         treesitter_context = true,
--         which_key = true,
--       },
--     },
--     specs = {
--       {
--         "akinsho/bufferline.nvim",
--         optional = true,
--         opts = function(_, opts)
--           if (vim.g.colors_name or ""):find("catppuccin") then
--             opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
--           end
--         end,
--       },
--     },
--   },
-- }
