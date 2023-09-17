return {
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            -- LSP Autocomplete
            "hrsh7th/cmp-nvim-lsp",

            -- Snippet Autocomplete
            {
                "saadparwaiz1/cmp_luasnip",
                dependencies = {
                    "L3MON4D3/LuaSnip",
                    "rafamadriz/friendly-snippets",
                },
            },

            -- Generic Autocomplete
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lua",
            "custompro98/cmp-kitty",
        },
    },
}
