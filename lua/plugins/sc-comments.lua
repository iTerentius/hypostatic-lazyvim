-- e.g. in lua/plugins/comments.lua (LazyVim style) or anywhere in your config
return {
  {
    "numToStr/Comment.nvim",
    opts = {
      -- Skip Comment.nvim's treesitter-based commentstring detection
      -- (Comment/ft.lua crashes walking the supercollider parser's tree)
      -- and just use the buffer's commentstring, which we set below.
      pre_hook = function()
        return vim.bo.commentstring
      end,
    },
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
