return {
  "davidgranstrom/scnvim",
  ft = "supercollider",
  keys = {
    { "<M-e>", mode = { "i", "n" }, desc = "Send line to SuperCollider" },
    { "<C-e>", mode = { "i", "n" }, desc = "Send block to SuperCollider" },
    { "<C-e>", mode = "x", desc = "Send selection to SuperCollider" },
    { "<CR>", desc = "Toggle post window" },
    { "<M-CR>", mode = "i", desc = "Toggle post window in insert mode" },
    { "<M-L>", mode = { "n", "i" }, desc = "Clear post window" },
    { "<C-k>", mode = { "n", "i" }, desc = "Show signature help" },
    { "<F12>", mode = { "n", "x", "i" }, desc = "Hard stop SuperCollider server" },
    { "<leader>st", desc = "Start SuperCollider server" },
    { "<leader>sk", desc = "Recompile SuperCollider code" },
    { "<F1>", expr = true, desc = "Boot SuperCollider server" },
    { "<F2>", expr = true, desc = "Show SuperCollider meter" },
  },
  config = function()
    local scnvim = require("scnvim")
    local map = scnvim.map
    local map_expr = scnvim.map_expr
    scnvim.setup({
      keymaps = {
        ['<M-e>'] = map('editor.send_line', {'i', 'n'}),
        ['<C-e>'] = {
          map('editor.send_block', {'i', 'n'}),
          map('editor.send_selection', 'x'),
        },
        ['<CR>'] = map('postwin.toggle'),
        ['<M-CR>'] = map('postwin.toggle', 'i'),
        ['<M-L>'] = map('postwin.clear', {'n', 'i'}),
        ['<C-k>'] = map('signature.show', {'n', 'i'}),
        ['<F12>'] = map('sclang.hard_stop', {'n', 'x', 'i'}),
        ['<leader>st'] = map('sclang.start'),
        ['<leader>sk'] = map('sclang.recompile'),
        ['<F1>'] = map_expr('s.boot'),
        ['<F2>'] = map_expr('s.meter'),
      },
      editor = {
        highlight = {
          color = 'IncSearch',
        },
      },
      postwin = {
        float = {
          enabled = true,
        },
      },
    })
  end,
}
