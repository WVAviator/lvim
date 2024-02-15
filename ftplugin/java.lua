local home = os.getenv("HOME")

local os_config = "linux"
if vim.fn.has "mac" == 1 then
  os_config = "mac"
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = home .. "/.cache/jdtls/workspace" .. project_name

local path_to_mason_packages = home .. "/.local/share/lvim/mason/packages"

local path_to_jdtls = path_to_mason_packages .. "/jdtls"


local path_to_config = path_to_jdtls .. "/config_" .. os_config
local lombok_path = path_to_jdtls .. "/lombok.jar"

local path_to_jar = vim.fn.glob(path_to_jdtls .. "/plugins/org.eclipse.equinox.launcher_*.jar")

-- local path_to_jdebug = path_to_mason_packages .. "/java-debug-adapter"
-- local path_to_jtest = path_to_mason_packages .. "/java-test"
--
local bundles = {}
-- local bundles = {
--   vim.fn.glob(path_to_jdebug .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true),
-- }

-- vim.list_extend(bundles, vim.split(vim.fn.glob(path_to_jtest .. "/extension/server/*.jar", true), "\n"))

local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "-javaagent:" .. lombok_path,
    "-Xbootclasspath/a:" .. lombok_path,
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar", path_to_jar,
    "-configuration", path_to_config,
    "-data", workspace_dir,
  },

  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = "all", -- literals, all, none
        },
      },
      format = {
        enabled = false,
      },
      signatureHelp = { enabled = true },
    },
  },
  root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew" },
}

local extendedClientCapabilities = require('jdtls').extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

config.init_options = {
  bundles = bundles,
  extendedClientCapabilities = extendedClientCapabilities,
}

lvim.builtin.dap.active = true

config.on_attach = function(client, bufnr)
  local _, _ = pcall(vim.lsp.codelens.refresh)

  require("jdtls").setup_dap({ hotcodereplace = "auto" })
  require("lvim.lsp").on_attach(client, bufnr)
  require("jdtls_dap").setup_dap_main_class_configs()
end


local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "google_java_format", filetypes = { "java" } },
}

require("jdtls").start_or_attach(config)

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local opts = {
  mode = "n",
  prefix = "<leader>",
  buffer = nil,
  silent = true,
  noremap = true,
  nowait = true,
}

local vopts = {
  mode = "v",
  prefix = "<leader>",
  buffer = nil,
  silent = true,
  noremap = true,
  nowait = true,
}

local mappings = {
  J = {
    name = "Java",
    o = { "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
    v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
    c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
    t = { "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Method" },
    T = { "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
    u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
  },
}

local vmappings = {
  J = {
    name = "Java",
    v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
    c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
    m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
  },
}

which_key.register(mappings, opts)
which_key.register(vmappings, vopts)
which_key.register(vmappings, vopts)
