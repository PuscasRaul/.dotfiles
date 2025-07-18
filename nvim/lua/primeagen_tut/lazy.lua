local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

local plugins = {
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { {'nvim-lua/plenary.nvim'} }
  },
  'HiPhish/rainbow-delimiters.nvim',
  'rose-pine/neovim',
  'RRethy/vim-illuminate',
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {}
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },
  'nvim-treesitter/playground',
  'ThePrimeagen/harpoon',
  'mbbill/undotree',
  'tpope/vim-fugitive',
  'folke/trouble.nvim',
  'mfussenegger/nvim-jdtls',
  'kovetskiy/neovim-move', build = ':UpdateRemotePlugins',
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },
  {
    'VonHeikemen/lsp-zero.nvim',
    dependencies = {
      {'neovim/nvim-lspconfig'},
      {
        'williamboman/mason-lspconfig.nvim',
      },
      {
        'mason-org/mason.nvim',
      },
      --Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      --Snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},
    }
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    }
  }
}
require("lazy").setup(plugins)
