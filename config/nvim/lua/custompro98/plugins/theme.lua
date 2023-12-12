return {
    {
        "catppuccin/nvim",
        config = function()
            require("catppuccin").setup({
                flavour = "mocha", -- latte, frappe, macchiato, mocha
                background = { -- :h background
                light = "latte",
                dark = "mocha",
            },
            compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
            transparent_background = true,
            term_colors = false,
            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 0.05,
            },
            styles = {
                comments = { "italic" },
                conditionals = { "italic" },
                loops = {},
                functions = {},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
            },
            color_overrides = {},
            custom_highlights = {},
            integrations = {
                cmp = true,
                mason = true,
                nvimtree = true,
                telescope = true,
                treesitter = true,
                -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
            },
        })

        -- vim.cmd.colorscheme("catppuccin")
    end,
},
{
    "mhartington/oceanic-next",
    config = function()
        -- vim.cmd.colorscheme "OceanicNext"
    end,
},
{
    "maxmx03/dracula.nvim",
    config = function()
        require("dracula").setup()

        vim.cmd.colorscheme("dracula")
    end,
},
}
