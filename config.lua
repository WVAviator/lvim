-- Vim configuration options
vim.diagnostic.config({ virtual_text = true, underline = true })
vim.opt.wrap = true
vim.opt.linebreak = true
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "jdtls" })

vim.api.nvim_create_user_command('Wa', 'wa', {})
vim.api.nvim_create_user_command('WA', 'wa', {})
vim.api.nvim_create_user_command('W', 'w', {})

lvim.format_on_save.enabled = true
lvim.builtin.treesitter.ensure_installed = {
  "java",
}

lvim.plugins = {
  "mfussenegger/nvim-jdtls",
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require('nvim-ts-autotag').setup()
    end
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({})
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup({
        suggestion = { enabled = false },
        panel = { enabled = false }
      })
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      require("tokyonight").setup({
        -- use the night style
        style = "night",
        -- disable italic for functions

        styles = {
          functions = { italic = false },
          keywords = { italic = false },
          expressions = { italic = false },
        },
        sidebars = { "qf", "vista_kind", "terminal", "packer" },
        -- Change the "hint" color to the "orange" color, and make the "error" color bright red
        on_colors = function(colors)
          colors.hint = colors.orange
          colors.error = "#dd0000"
        end
      })
    end
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  {
    "simrat39/rust-tools.nvim",
    config = function()
      -- local lsp_installer_servers = require("nvim-lsp-installer.servers")
      -- local _, requested_server = lsp_installer_servers.get_server("rust_analyzer")
      require("rust-tools").setup({
        tools = {
          autoSetHints = true,
          -- hover_with_actions = true,
          -- options same as lsp hover / vim.lsp.util.open_floating_preview()
          hover_actions = {

            -- the border that is used for the hover window
            -- see vim.api.nvim_open_win()
            border = {
              { "╭", "FloatBorder" },
              { "─", "FloatBorder" },
              { "╮", "FloatBorder" },
              { "│", "FloatBorder" },
              { "╯", "FloatBorder" },
              { "─", "FloatBorder" },
              { "╰", "FloatBorder" },
              { "│", "FloatBorder" },
            },

            -- whether the hover action window gets automatically focused
            -- default: false
            auto_focus = true,
          },
          runnables = {
            use_telescope = true,
          },
        },
        server = {
          on_init = require("lvim.lsp").common_on_init,
          on_attach = function(client, bufnr)
            require("lvim.lsp").common_on_attach(client, bufnr)
            local rt = require("rust-tools")
            -- Hover actions
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<leader>lA", rt.code_action_group.code_action_group, { buffer = bufnr })
          end,
        },
      })
    end,
    ft = { "rust", "rs" },
  }
}

lvim.colorscheme = "tokyonight-night"
-- Below config is required to prevent copilot overriding Tab with a suggestion
-- when you're just trying to indent!
local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end
local on_tab = vim.schedule_wrap(function(fallback)
  local cmp = require("cmp")
  if cmp.visible() and has_words_before() then
    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
  else
    fallback()
  end
end)
lvim.builtin.cmp.mapping["<Tab>"] = on_tab

-- Emmet Setup
require("lvim.lsp.manager").setup("emmet_ls")

require("lvim.lsp.manager").setup("cssls", {
  settings = {
    css = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
    scss = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
    less = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
  },
})


local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  {
    name = "prettier",
    args = { "--print-width", "80" },
    filetypes = { "typescript", "typescriptreact" },
  },
}

require 'nvim-treesitter.configs'.setup {
  autotag = {
    enable = true,
  }
}
