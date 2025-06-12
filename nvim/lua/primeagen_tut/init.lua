require("primeagen_tut.remap")
require("primeagen_tut.lazy")
require("primeagen_tut.autocmd")
print("hello from the primeagen")

vim.api.nvim_set_hl(0, "Comment", { fg = "#D87C74", italic = true })
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.scrolloff = 999
vim.opt.colorcolumn= "80"
vim.keymap.set("", "<Up>", "<Nop>", {silent = true})
vim.keymap.set("", "<Down>", "<Nop>", {silent = true})
vim.keymap.set("", "<Left>", "<Nop>", {silent = true})
vim.keymap.set("", "<Right>", "<Nop>", {silent = true})
vim.keymap.set("v", "<leader>y", "+y", {silent=true})

