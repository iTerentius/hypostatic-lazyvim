return {
  { "nvzone/volt", lazy = true },

  {
    "nvzone/minty",
    cmd = { "Shades", "Huefy" },
    keys = {
      { "<leader>cp", "<cmd>Huefy<cr>", desc = "Color Picker (Huefy)" },
      { "<leader>cs", "<cmd>Shades<cr>", desc = "Color Picker (Shades)" },
    },
  }
}

