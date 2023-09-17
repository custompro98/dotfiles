-- ** Copy Paste ** --

function SmartPaste()
    vim.opt.paste = true
    vim.cmd("normal \"+p")
    vim.opt.paste = false
end

vim.keymap.set("n", "<Leader>v", SmartPaste, {})
vim.keymap.set("v", "<Leader>c", "\"+y", {})
