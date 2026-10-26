-- ** Init ** --

vim.loader.enable()

vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

vim.g.have_nerd_font = true

-- non-plugin configuration
local nonplugins_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "custompro98")
local files = vim.fn.readdir(nonplugins_dir, function(name)
	return name:match("%.lua$") and name ~= "init.lua" and 1 or 0
end)
for _, file_name in ipairs(files) do
	local module = file_name:gsub("%.lua$", "")
	require("custompro98." .. module)
end

-- plugin configuration
require("custompro98.plugins")

-- set company overrides (if applicable)
local override_path = "~/.config/nvim/override/after"
vim.opt.runtimepath:append(override_path)
