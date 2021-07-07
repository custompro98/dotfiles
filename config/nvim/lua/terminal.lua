local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Terminal ** --

-- enter terminal mode
api.nvim_set_keymap('n', '<Leader>t', ':lua OpenWindow("botright", vim.api.nvim_list_uis()[1].height/5, "split|terminal")<CR>', { noremap = true })

-- leave terminal mode
api.nvim_set_keymap('t', '<Leader>t', '<C-\\><C-n>', { noremap = true })
api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', {})

function OpenWindow(position, height, cmd)
  vim.cmd(position..height..cmd)
end
