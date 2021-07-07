local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Copy/Paste ** --

api.nvim_set_keymap('n', '<Leader>v', ':lua SmartPaste()<CR>', { noremap = true})
api.nvim_set_keymap('v', '<Leader>c', '"+y', { noremap = true})

function SmartPaste()
  opt.paste = true
  vim.cmd('normal "+p')
  opt.paste = false
end
