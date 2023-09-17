return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function ()
            require("nvim-tree").setup({
                -- disables netrw completely
                disable_netrw       = false,
                -- hijack netrw window on startup
                hijack_netrw        = true,
                -- opens the tree when changing/opening a new tab if the tree wasn"t previously opened
                open_on_tab         = false,
                -- hijacks new directory buffers when they are opened.
                hijack_directories  = {
                    -- enable the feature
                    enable = true,
                    -- allow to open the tree if it was previously closed
                    auto_open = true,
                },
                -- hijack the cursor in the tree to put it at the start of the filename
                hijack_cursor       = false,
                -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
                update_cwd          = false,
                -- show lsp diagnostics in the signcolumn
                diagnostics = {
                    enable = false,
                    icons = {
                        hint = "⁉️",
                        info = "ℹ️",
                        warning = "⚠️",
                        error = "❌",
                    }
                },
                -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
                update_focused_file = {
                    -- enables the feature
                    enable      = false,
                    -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
                    -- only relevant when `update_focused_file.enable` is true
                    update_cwd  = false,
                    -- list of buffer names / filetypes that will not update the cwd if the file isn"t found under the current root directory
                    -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
                    ignore_list = {}
                },
                -- configuration options for the system open command (`s` in the tree by default)
                system_open = {
                    -- the command to run this, leaving nil should work in most cases
                    cmd  = nil,
                    -- the command arguments as a list
                    args = {}
                },

                view = {
                    -- width of the window, can be either a number (columns) or a string in `%`, for left or right side placement
                    width = 30,
                    -- side of the tree, can be one of "left" | "right" | "top" | "bottom"
                    side = "left",
                },

                actions = {
                    open_file = {
                        resize_window = false
                    },
                },
            })

            -- Open the file tree
            vim.keymap.set("n", "<C-\\>", function()
                require("nvim-tree.api").tree.toggle(true, false)
            end, { noremap = true })
        end,
    },
}
