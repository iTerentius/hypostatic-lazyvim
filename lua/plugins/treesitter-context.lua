return {
  "nvim-treesitter/nvim-treesitter-context",
  opts = { mode = "cursor", max_lines = 4 },
}

  config = function(_, opts)
    require("treesitter-context").setup(opts)

    -- Make the sticky header visually distinct
    vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#2e3440" })      -- main line
    vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { bg = "#2e3440" })
    vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "#5e81ac" })
  end,
}
