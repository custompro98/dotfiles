-- ** Init ** --

vim.loader.enable()

vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

vim.g.have_nerd_font = true

-- non-plugin configuration
local nonplugins_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "custompro98_v2")
for file_name, type in vim.fs.dir(nonplugins_dir) do
	if type == "file" and file_name:match("%.lua$") and file_name ~= "init.lua" then
		local module = file_name:gsub("%.lua$", "")
		require("custompro98_v2." .. module)
	end
end

-- plugin configuration
require("custompro98_v2.plugins")

-- set company overrides (if applicable)
local override_path = "~/.config/nvim/override/after"
vim.opt.runtimepath:append(override_path)
