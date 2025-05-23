return {
	{
		"azorng/goose.nvim",
		config = function()
			require("goose").setup({
				providers = {
					google = {
						"gemini-2.0-flash",
					},
					ollama = {
						"devstral",
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
