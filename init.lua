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
vim.opt.clipboard = 'unnamedplus'

vim.opt.rtp:prepend(lazypath)
vim.opt.number = true
vim.opt.relativenumber = true
-- lazy.nvimのセットアップ
require('lazy').setup({
    -- LSPサポート
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim', -- LSPサーバーの自動インストール
            'williamboman/mason-lspconfig.nvim', -- Masonとlspconfigの統合
        },
    },
    -- オートコンプリートエンジン
    {
        'hrsh7th/nvim-cmp', -- 補完プラグイン
        dependencies = {
            'hrsh7th/cmp-nvim-lsp', -- LSPを使った補完
            'hrsh7th/cmp-buffer', -- バッファ補完
            'hrsh7th/cmp-path', -- パス補完
            'hrsh7th/cmp-cmdline', -- コマンドライン補完
        },
    },
    -- スニペットサポート
    {
        'L3MON4D3/LuaSnip', -- スニペットエンジン
        dependencies = {
            'saadparwaiz1/cmp_luasnip', -- cmpとスニペットの連携
        },
    },
})

-- Masonの設定とLSPサーバーのインストール
require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = { 'pyright', 'html', 'cssls', 'ts_ls' }, -- インストールするLSPサーバー
})

-- LSPサーバーの設定
local lspconfig = require('lspconfig')

-- Python用LSPサーバー
lspconfig.pyright.setup{}

-- HTML用LSPサーバー
lspconfig.html.setup{}

-- CSS用LSPサーバー
lspconfig.cssls.setup{}

-- JavaScript/TypeScript用LSPサーバー
lspconfig.ts_ls.setup{}

-- nvim-cmpの設定
local cmp = require('cmp')

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Enterキーで補完を確定
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- スニペット補完
    }, {
        { name = 'buffer' }, -- バッファからの補完
        { name = 'path' },   -- パスの補完
    })
})

-- jjで挿入モードからノーマルモードに戻る設定
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })
-- HTML, CSS, JS の場合タブ幅2に設定
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "javascript" },
  callback = function()
    vim.opt_local.tabstop = 2      -- タブ幅を2に
    vim.opt_local.shiftwidth = 2   -- インデント幅を2に
    vim.opt_local.expandtab = true -- タブをスペースに変換
  end,
})

-- Python の場合タブ幅4に設定
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4      -- タブ幅を4に
    vim.opt_local.shiftwidth = 4   -- インデント幅を4に
    vim.opt_local.expandtab = true -- タブをスペースに変換
  end,
})
