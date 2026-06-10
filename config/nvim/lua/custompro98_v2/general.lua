-- ** General ** --

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- nowrap
vim.wo.wrap = false
vim.o.breakindent = true

-- no mouse mode
vim.o.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- save undo history
vim.o.undofile = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true
