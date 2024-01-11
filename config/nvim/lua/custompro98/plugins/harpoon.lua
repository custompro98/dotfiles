return {
	{
		"ThePrimeagen/harpoon",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		branch = "harpoon2",
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			vim.keymap.set("n", "<Leader>ha", function()
				harpoon:list():append()
			end)

			vim.keymap.set("n", "<Leader>hu", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end)

			vim.keymap.set("n", "<Leader>a", function()
				harpoon:list():select(1)
			end)

			vim.keymap.set("n", "<Leader>s", function()
				harpoon:list():select(2)
			end)

			vim.keymap.set("n", "<Leader>d", function()
				harpoon:list():select(3)
			end)

			vim.keymap.set("n", "<leader>p", function()
				harpoon:list():prev()
			end)

			vim.keymap.set("n", "<Leader>n", function()
				harpoon:list():next()
			end)
		end,
	},
}
