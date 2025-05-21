return {
	{
		"azorng/goose.nvim",
		config = function()
			require("goose").setup({
				providers = {
					google = {
						"gemini-2.5-flash-preview-05-20",
					},
				},
			})
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					anti_conceal = { enabled = false },
				},
			},
		},
	},
}
