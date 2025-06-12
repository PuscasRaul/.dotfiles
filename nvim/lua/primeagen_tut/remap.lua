vim.g.mapleader = " "
vim.keymap.set( "n", "<leader>q", vim.cmd.Ex)
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map("n", "<leader>h", "<C-w>h", opts)
map("n", "<leader>j", "<C-w>j", opts)
map("n", "<leader>k", "<C-w>k", opts)
map("n", "<leader>l", "<C-w>l", opts)
map("n", "<leader>x", ":close<CR>", opts)
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

