local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>ps', builtin.grep_string, { desc = 'Telescope Grep current word' })
vim.keymap.set('n', '<leader>pg', builtin.live_grep, { desc = 'Telescope Live Grep content' })
