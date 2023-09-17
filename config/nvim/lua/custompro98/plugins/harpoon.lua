return {
    {
        "ThePrimeagen/harpoon",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function ()
            vim.keymap.set('n', '<Leader>ha', require('harpoon.mark').add_file, { noremap = true })
            vim.keymap.set('n', '<Leader>hu', require('harpoon.ui').toggle_quick_menu, { noremap = true })
            vim.keymap.set('n', '<Leader>a', function() require('harpoon.ui').nav_file(1) end, { noremap = true })
            vim.keymap.set('n', '<Leader>s', function() require('harpoon.ui').nav_file(2) end, { noremap = true })
            vim.keymap.set('n', '<Leader>d', function() require('harpoon.ui').nav_file(3) end, { noremap = true })
            vim.keymap.set('n', '<Leader>f', function() require('harpoon.ui').nav_file(4) end, { noremap = true })
        end
    },
}
