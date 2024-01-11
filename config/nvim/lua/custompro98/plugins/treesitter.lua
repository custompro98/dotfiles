return {
    {
        {
            "nvim-treesitter/nvim-treesitter",
            dependencies = {
                "nvim-treesitter/nvim-treesitter-textobjects",
                "nvim-treesitter/playground",
                { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
                "windwp/nvim-ts-autotag",
                "vrischmann/tree-sitter-templ", -- enable custom treesitter highlighting for templ
            },
            build = ":TSUpdate",
            config = function()
                require("nvim-treesitter.configs").setup({
                    highlight = {
                        enable = true,
                        disable = {},
                    },
                    indent = {
                        enable = false,
                        disable = {},
                    },
                    query_linter = {
                        enable = true,
                        use_virtual_text = true,
                        lint_events = { "BufWrite", "CursorHold" },
                    },
                    ensure_installed = "all",
                    ignore_install = { "phpdoc", "haskell" },
                    autopairs = { enable = true },
                    autotag = { enable = true },
                    textobjects = {
                        select = {
                            enable = true,

                            -- Automatically jump forward to textobj, similar to targets.vim
                            lookahead = true,

                            keymaps = { -- You can use the capture groups defined in textobjects.scm
                                ["af"] = "@function.outer",
                                ["if"] = "@function.inner",
                                ["ac"] = "@class.outer",
                                ["ic"] = "@class.inner",
                                ["aP"] = "@parameter.outer",
                                ["iP"] = "@parameter.inner",
                            },
                        },
                    },
                })

                local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
                parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
                parser_config.templ = {
                    install_info = {
                        url = "https://github.com/vrischmann/tree-sitter-templ.git",
                        files = { "src/parser.c", "src/scanner.c" },
                        branch = "master",
                    },
                }
            end,
        },
    },
}
