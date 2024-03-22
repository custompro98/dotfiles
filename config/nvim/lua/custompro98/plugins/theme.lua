return {
	{
		"maxmx03/dracula.nvim",
		config = function()
			require("dracula").setup({})

			vim.cmd.colorscheme("dracula")
		end,
	},
}
