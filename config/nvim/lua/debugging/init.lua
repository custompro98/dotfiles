-- ** DAP Configuration ** --

require('telescope').load_extension('dap')
require('dapui').setup()

local bufopts = { noremap = true, silent = true }

-- DAP mappings
vim.keymap.set('n', '<Leader>dc', require('dap').continue, bufopts)
vim.keymap.set('n', '<Leader>dsv', require('dap').step_over, bufopts)
vim.keymap.set('n', '<Leader>dsi', require('dap').step_into, bufopts)
vim.keymap.set('n', '<Leader>dso', require('dap').step_out, bufopts)

vim.keymap.set('n', '<Leader>db', require('dap').toggle_breakpoint, bufopts)
vim.keymap.set('n', '<Leader>dbc', function() require('dap').set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, bufopts)
vim.keymap.set('n', '<Leader>dbl', function() require('dap').set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, bufopts)

vim.keymap.set('n', '<Leader>dro', require('dap').repl.open, bufopts)

-- DAP Telescope mappings
vim.keymap.set('n', '<Leader>dtc', function() require('telescope').extensions.dap.commands{} end, bufopts)
vim.keymap.set('n', '<Leader>dtb', function() require('telescope').extensions.dap.list_breakpoints{} end, bufopts)
vim.keymap.set('n', '<Leader>dtv', function() require('telescope').extensions.dap.variables{} end, bufopts)
vim.keymap.set('n', '<Leader>dtf', function() require('telescope').extensions.dap.frames{} end, bufopts)

-- DAP UI mappings
vim.keymap.set('n', '<Leader>dui', require('dapui').toggle, bufopts)
vim.keymap.set('n', '<Leader>duh', require('dapui').eval, bufopts)
vim.keymap.set('v', '<Leader>duh', require('dapui').eval, bufopts)

require('debugging.typescript')
