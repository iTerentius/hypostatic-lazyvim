-- e.g. in lua/plugins/comments.lua (LazyVim style) or anywhere in your config
return {
  {
    "numToStr/Comment.nvim",
    opts = {},
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "supercollider", "scd" },
        callback = function()
          vim.bo.commentstring = "// %s"
        end,
      })
    end,
  },
}
