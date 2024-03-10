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
    "rebelot/kanagawa.nvim",
    config = function()
      require("kanagawa").setup({
        commentStyle = { italic = false },
        keywordStyle = { italic = false },
        overrides = function()
          return {
            ["@variable.builtin"] = { italic = false },
          }
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
}

lvim.colorscheme = "kanagawa-wave"

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

-- Not sure why this doesn't work
-- require("lvim.lsp.manager").setup("rust_analyzer", {
--   settings = {
--     ["rust_analyzer"] = {
--       rustfmt = {
--         overrideCommand = { "leptosfmt", "--stdin", "--rustfmt" },
--       }
--     }
--   }
-- })

-- Using this instead
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.rs",
  callback = function()
    local found = vim.fn.search("view!", "nw")
    if found > 0 then
      local filepath = vim.fn.expand('%:p')
      vim.fn.system('leptosfmt ' .. filepath)
      vim.cmd('edit!')
    end
  end
})

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


require("lvim.lsp.manager").setup("tailwindcss", {
  filetypes = { "css", "scss", "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "rust" },
  init_options = {
    userLanguages = {
      rust = "html",
    }
  },
  root_dir = require("lspconfig").util.root_pattern("tailwind.config.js"),
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
