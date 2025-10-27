-- File: ~/.config/nvim/ftplugin/java.lua
-- Purpose: Start/attach JDTLS per project, DAP & Test bundles, IntelliJ-like keymaps

local ok, jdtls = pcall(require, "jdtls")
if not ok then return end

-- Detect project root (Maven/Gradle/Git)
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if not root_dir or root_dir == "" then return end

-- Unique workspace per project (like IntelliJ .idea)
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- Resolve Mason paths
local mr = require("mason-registry")
local jdtls_pkg = mr.get_package("jdtls")
local jdtls_path = jdtls_pkg:get_install_path()

-- Pick whichever config_* dir actually exists (mac/linux/win)
local function pick_config_dir(base)
  for _, d in ipairs({ "config_mac", "config_linux", "config_win" }) do
    if vim.fn.isdirectory(base .. "/" .. d) == 1 then
      return d
    end
  end
  return nil
end
local config_dir = pick_config_dir(jdtls_path)
if not config_dir then
  vim.notify("jdtls: no config_* directory found under " .. jdtls_path, vim.log.levels.ERROR)
  return
end

-- Optional: Lombok support (helpful for Spring, builders, etc.)
local lombok_jar = jdtls_path .. "/lombok.jar"

-- Gather Debug & Test bundles (DAP + JUnit)
local bundles = {}
local function extend_glob(pkg, pattern)
  local ok_pkg, p = pcall(mr.get_package, pkg)
  if ok_pkg then
    local path = p:get_install_path()
    local jars = vim.split(vim.fn.glob(path .. pattern), "\\n") -- IMPORTANT: literal \n
    for _, j in ipairs(jars) do
      if j ~= "" then table.insert(bundles, j) end
    end
  end
end
extend_glob("java-debug-adapter", "/extension/server/com.microsoft.java.debug.plugin-*.jar")
extend_glob("java-test", "/extension/server/*.jar")

-- Build command
local cmd = {
  jdtls_path .. "/bin/jdtls",
  "-configuration", jdtls_path .. "/" .. config_dir,
  "-data", workspace_dir,
}
-- Only add lombok if present
if vim.fn.filereadable(lombok_jar) == 1 then
  table.insert(cmd, 1, "-javaagent:" .. lombok_jar)
  table.insert(cmd, 1, "-Xbootclasspath/a:" .. lombok_jar)
end

-- IntelliJ-like keymaps on attach
local function on_attach(_, bufnr)
  local map = function(m, lhs, rhs, desc)
    vim.keymap.set(m, lhs, rhs, { buffer = bufnr, desc = desc })
  end
  -- LSP
  map("n", "<F6>", vim.lsp.buf.rename, "Rename (Shift+F6)")
  map("n", "<C-b>", vim.lsp.buf.definition, "Go to Definition (Ctrl+B)")
  map("n", "gI", vim.lsp.buf.implementation, "Go to Implementation")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action (Alt+Enter)")
  map("n", "K", vim.lsp.buf.hover, "Quick Docs")
  map("n", "<leader>sr", require("telescope.builtin").lsp_document_symbols, "Search Symbols")
  map("n", "<leader>oi", jdtls.organize_imports, "Organize Imports")

  -- Java-specific
  map("n", "<leader>tt", jdtls.test_nearest_method, "Test Nearest")
  map("n", "<leader>tT", jdtls.test_class, "Test Class")
  map("v", "<leader>em", function() jdtls.extract_method(true) end, "Extract Method")
  map("n", "<leader>ev", jdtls.extract_variable, "Extract Variable")
  map("n", "<leader>ec", jdtls.extract_constant, "Extract Constant")

  -- DAP
  local dap = require("dap")
  local dapui = require("dapui")
  map("n", "<F5>", dap.continue, "Debug: Continue")
  map("n", "<F9>", dap.toggle_breakpoint, "Debug: Breakpoint")
  map("n", "<F10>", dap.step_over, "Debug: Step Over")
  map("n", "<F11>", dap.step_into, "Debug: Step Into")
  map("n", "<F12>", dap.step_out, "Debug: Step Out")
  map("n", "<leader>du", dapui.toggle, "Debug UI")
  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
end

-- Capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then capabilities = cmp_lsp.default_capabilities(capabilities) end

local settings = {
  java = {
    signatureHelp = { enabled = true },
    contentProvider = { preferred = "fernflower" },
    completion = { favoriteStaticMembers = { "org.junit.Assert.*", "org.mockito.Mockito.*", "java.util.Objects.*" } },
    format = { enabled = true },
    configuration = { updateBuildConfiguration = "interactive" },
  },
}

-- JDTLS: register commands & enable DAP (no require('dap').setup()!)
-- require("jdtls.setup").add_commands()
-- jdtls.setup_dap({ hotcodereplace = "auto" })

-- Start/attach
jdtls.start_or_attach({
  cmd = cmd,
  root_dir = root_dir,
  on_attach = on_attach,
  capabilities = capabilities,
  settings = settings,
  init_options = { bundles = bundles },
})

