local vim = vim

-- ** Terminal ** --

-- enter terminal mode
vim.keymap.set("n", "<Leader>t", function () OpenWindow("botright", vim.api.nvim_list_uis()[1].height/5, "split|terminal") end, { noremap = true })

-- leave terminal mode
vim.keymap.set("t", "<Leader>t", "<C-\\><C-n>", {})
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { remap = true })

function OpenWindow(position, height, cmd)
  vim.cmd(position..height..cmd)
end
