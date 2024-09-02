-- lazy.nvimのパスを指定
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- 最新の安定版を使用
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.number = true
vim.opt.relativenumber = true
-- 'jj' を ESC キーとしてマッピング
vim.api.nvim_set_keymap('i', 'jj', '<ESC>', { noremap = true, silent = true })

-- ヤンク (コピー) を Ctrl+C にマッピング
vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true, silent = true })

-- ペーストを Ctrl+V にマッピング
vim.api.nvim_set_keymap('n', '<C-v>', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-v>', '<C-r>+', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-f>', '<Right>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-h>', '<BS>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'x', '"_x', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'd', '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'c', '"_c', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'x', '"_x', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'd', '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'c', '"_c', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
-- システムクリップボードを使う
vim.opt.clipboard = "unnamedplus"

-- lazy.nvimを使用したプラグインのセットアップ
require("lazy").setup({

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup{
        defaults = {
          file_ignore_patterns = { "deps", "_build" },  -- Elixirプロジェクト特有のフォルダを除外
        },
      }
    end,
  },
-- Elixir LSP
{
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")

    -- ElixirLS
    lspconfig.elixirls.setup({
      cmd = { "/Users/aran/.config/nvim/elixir-ls/scripts/language_server.sh" }, -- ElixirLSのパスを指定
      settings = {
        elixirLS = {
          dialyzerEnabled = false,   -- Dialyzer（静的コード解析ツール）を無効化
          fetchDeps = false,         -- 自動依存関係取得を無効化
        }
      },
    })

    -- Python LSP (pyright)
    lspconfig.pyright.setup{}

    -- HTML LSP
    require("lspconfig").html.setup{
      cmd = { "vscode-html-language-server", "--stdio" },
    }
    -- TailwindCSS LSP
    lspconfig.tailwindcss.setup({
      cmd = { "tailwindcss-language-server", "--stdio" }  -- グローバルにインストールされたものを使用
    })
  end,
},
  -- 補完エンジン
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },

  -- スニペットエンジン
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- Treesitter (シンタックスハイライト)
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "elixir", "heex", "eex", "html", "css", "javascript", "python" },
        highlight = {
          enable = true,
        },
      }
    end,
  },

  -- Lualine (ステータスライン)
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "gruvbox",  -- テーマを設定
          section_separators = '',
          component_separators = '',
        },
        sections = {
          lualine_c = {'filename', 'branch'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
        },
      })
    end,
  },

  -- Mason (LSPサーバーの管理)
  {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "elixirls", "pyright", "html", "tailwindcss" },
      })
    end,
  },

  -- Formatter (コードフォーマッタ)
  {
    "mhartington/formatter.nvim",
    config = function()
      require("formatter").setup({
        filetype = {
          elixir = {
            function()
              return {
                exe = "mix",
                args = { "format", "-" },
                stdin = true,
              }
            end,
          },
          python = {
            function()
              return {
                exe = "black", -- Pythonのフォーマッタ
                args = { "--fast", "-" },
                stdin = true,
              }
            end,
          },
          html = {
            function()
              return {
                exe = "prettier", -- Prettierを使ってHTMLを整形
                args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
                stdin = true,
              }
            end,
          },
          css = {
            function()
              return {
                exe = "prettier", -- Prettierを使ってCSSを整形
                args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
                stdin = true,
              }
            end,
          },
        },
      })
    end,
  },
  -- nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    requires = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
        },
      })
    end,
  },

  -- TailwindCSS補完
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require('Comment').setup()
    end
  },
})
