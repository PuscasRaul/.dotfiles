require('mason').setup({})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
lsp_capabilities.signatureHelpProvider = false  -- Add this line

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP keybindings',
  callback = function(event)
    local opts = {buffer = event.buf}

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  end
})

-------- LUASNIP CONFING
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
ls.filetype_set("cpp", { "c" })
ls.add_snippets("all", {
	s("autotrigger", {
		t("autosnippet"),
	}),
}, {
	type = "autosnippets",
	key = "all_auto",
})

-------- CMP CONFING
local cmp = require('cmp')
cmp.setup({
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'nvim_lua'},
  },
  mapping = cmp.mapping.preset.insert({
    ['<S-Tab>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<Tab>'] = cmp.mapping.select_next_item(cmp_select),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  window = {
    documentation = cmp.config.window.bordered(),
  },
})

vim.filetype.add({
  extension = {
    fxml = "xml",
    axaml = "xml"
  }
})

local lspconfig = require('lspconfig')
local util = require('lspconfig.util')

lspconfig.clangd.setup{}
lspconfig.lua_ls.setup{}
lspconfig.pyright.setup{}
lspconfig.sqlls.setup{}
lspconfig.lemminx.setup{}
lspconfig.omnisharp.setup{}
lspconfig.intelephense.setup{}
lspconfig.html.setup{}
lspconfig.cssls.setup{}

lspconfig.arduino_language_server.setup({
  cmd = {
    "arduino-language-server",
    "-cli", "/home/raulpuscas/bin/arduino-cli",
    "-fqbn", "arduino:avr:uno",
    "-clangd", "clangd",
  },
  filetypes = { "ino"},
})

lspconfig.angularls.setup({
  root_dir = util.root_pattern("angular.json", "project.json"),
})

lspconfig.vtsls.setup({
  root_dir = function(fname)
    local angular_root = util.root_pattern("angular.json", "project.json")(fname)
    if angular_root then
      return nil
    end
    return util.root_pattern("tsconfig.json", "package.json", ".git")(fname)
  end,
})
