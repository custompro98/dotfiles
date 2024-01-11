local tooling_by_ft = {
	lua = {
		form = { "stylua" },
		lint = {},
	},
}

function AllTools()
	local everything = {}

	for ft in pairs(tooling_by_ft) do
		for tool in pairs(tooling_by_ft[ft]) do
			for _, member in ipairs(tooling_by_ft[ft][tool]) do
				if type(member) == "table" then
					for _, submember in ipairs(member) do
						table.insert(everything, submember)
					end
				else
					table.insert(everything, member)
				end
			end
		end
	end

	return everything
end

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "j-hui/fidget.nvim", opts = {} },
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			dependencies = {
				"williamboman/mason.nvim",
			},
			opts = {
				ensure_installed = AllTools(),
			},
		},
		{
			"mfussenegger/nvim-lint",
			config = function()
				require("lint").linters_by_ft = {}
			end,
		},
		{
			"stevearc/conform.nvim",
			config = function()
				require("conform").setup({
					formatters_by_ft = {
						lua = tooling_by_ft["lua"].form,
					},
					format_on_save = {
						timeout_ms = 500,
						lsp_fallback = false,
					},
				})
			end,
		},
	},
	config = function()
		local servers = {
			lua_ls = {
				format = false,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			},
		}

		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = vim.tbl_keys(servers),
		})

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

		local on_attach = function(client, bufnr)
			local bufopts = { noremap = true, silent = true, buffer = bufnr }

			vim.diagnostic.config({ virtual_text = true })

			-- mapping
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
			vim.keymap.set("n", "gh", vim.lsp.buf.hover, bufopts)
			vim.keymap.set("i", "<Leader>gh", vim.lsp.buf.signature_help, bufopts)
			vim.keymap.set("n", "<Leader>D", vim.lsp.buf.type_definition, bufopts)
			vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
			vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)

			if not servers[client.name].format then
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false

				vim.keymap.set("n", "<Leader>f", function()
					require("conform").format({
						timeout_ms = 500,
						bufnr = bufnr,
					})
				end, bufopts)
			else
				vim.keymap.set("n", "<Leader>f", vim.lsp.buf.format, bufopts)
			end

			vim.keymap.set("n", "<Leader>;", function()
				vim.diagnostic.open_float(nil, { focus = false })
			end, bufopts)

			vim.keymap.set("n", "<C-p>", vim.diagnostic.goto_prev, bufopts)
			vim.keymap.set("n", "<C-n>", vim.diagnostic.goto_next, bufopts)
		end

		require("mason-lspconfig").setup_handlers({
			function(server_name)
				require("lspconfig")[server_name].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					settings = (servers[server_name] or {}).settings,
					filetypes = (servers[server_name] or {}).filetypes,
				})
			end,
		})
	end,
}
