local vim = vim
local opt = vim.opt

-- ** Copy/Paste ** --
function SmartPaste()
  opt.paste = true
  vim.cmd("normal \"+p")
  opt.paste = false
end

vim.keymap.set("n", "<Leader>v", SmartPaste, {})
vim.keymap.set("v", "<Leader>c", "\"+y", {})

