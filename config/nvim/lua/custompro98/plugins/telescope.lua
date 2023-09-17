return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = "make",
                cond = function()
                    return vim.fn.executable "make" == 1
                end,
            },
            "nvim-telescope/telescope-live-grep-args.nvim"
        },
        config = function ()
            require("telescope").setup({
                extensions = {
                    fzf = {
                        fuzzy = true,                    -- false will only do exact matching
                        override_generic_sorter = true,  -- override the generic sorter
                        override_file_sorter = true,     -- override the file sorter
                        case_mode = "smart_case",        -- "smart_case" or "ignore_case" or "respect_case"
                    },
                    live_grep_args = {
                        auto_quoting = true,
                        mappings = {
                            i = {
                                ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
                                ["<C-j>"] = require("telescope-live-grep-args.actions").quote_prompt({ postfix = " --iglob " }),
                                ["<C-l>"] = require("telescope-live-grep-args.actions").quote_prompt({ postfix = " -t " }),
                            },
                        },
                    },
                },
                defaults = {
                    mappings = {
                        i = {
                            ["<Leader>q"] = require("telescope.actions").send_selected_to_qflist + require("telescope.actions").open_qflist,
                        },
                        n = {
                            ["<Leader>q"] = require("telescope.actions").send_selected_to_qflist + require("telescope.actions").open_qflist,
                        },
                    },
                },
            })

            require("telescope").load_extension("fzf")
            require("telescope").load_extension("live_grep_args")
            -- require("telescope").load_extension("dap")

            function TelescopeDotfiles()
                require("telescope.builtin").git_files {
                    cwd = "~/.dotfiles/",
                }
            end

            vim.keymap.set("n", "<Leader>ff", "<cmd>Telescope find_files<CR>", {})
            vim.keymap.set("n", "<Leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", {})
            vim.keymap.set("n", "<Leader>fr", "<cmd>Telescope lsp_references<CR>", {})
            vim.keymap.set("n", "<Leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", {})
            vim.keymap.set("n", "<Leader>fh", "<cmd>Telescope help_tags<CR>", {})
            vim.keymap.set("n", "<Leader>fd", "<cmd>lua TelescopeDotfiles()<CR>", {})
            vim.keymap.set("n", "<Leader>fm", "<cmd>Telescope man_pages<CR>", {})
            vim.keymap.set("n", "<Leader>fb", "<cmd>Telescope buffers<CR>", {})
        end
    },
}
