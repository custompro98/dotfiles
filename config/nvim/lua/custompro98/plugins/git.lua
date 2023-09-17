return {
    {
        "tpope/vim-fugitive",
        config = function ()
            vim.keymap.set('n', '<Leader>gb', ':Git blame<CR>', {})
            vim.keymap.set('n', '<Leader>gd', ':Git diff %<CR>', {})
        end
    },
    "tpope/vim-rhubarb",
}
