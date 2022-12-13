local vim = vim

-- ** Git ** --

vim.keymap.set('n', '<Leader>gb', ':Git blame<CR>', {})
vim.keymap.set('n', '<Leader>gd', ':Git diff %<CR>', {})

