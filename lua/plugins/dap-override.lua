
-- Hard-stop any auto config of nvim-dap (some distros/configs try to call dap.setup())
return {
  {
    "mfussenegger/nvim-dap",
    config = false,  -- don't run any config() attached elsewhere
    opts = false,    -- don't pass opts to a non-existent setup
  },
}
