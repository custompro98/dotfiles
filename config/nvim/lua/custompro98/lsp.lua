-- ** LSP ** --

local function has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

local servers = {
	dockerls = {},
	gopls = {},
	lua_ls = {
		settings = {
			Lua = {
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
			},
		},
	},
	terraformls = {},
	denols = {
		single_file_support = false,
		root_dir = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc"),
	},
	tsserver = {
		single_file_support = false,
		root_dir = require("lspconfig.util").root_pattern("package.json"),
		filetypes = {
			"typescript",
			"typescriptreact",
			"javascript",
			"javascriptreact",
			"json",
			"json5",
		},
	},
	graphql = {},
	tailwindcss = {
		root_dir = require("lspconfig.util").root_pattern(
			"tailwind.config.js",
			"tailwind.config.ts",
			"twind.config.ts"
		),
	},
	bufls = {},
	rust_analyzer = {
		cmd = { "rustup", "run", "stable", "rust-analyzer" },
		settings = {
			["rust-analyzer"] = {
				imports = {
					granularity = {
						group = "module",
					},
					prefix = "self",
				},
				cargo = {
					buildScripts = {
						enable = true,
					},
				},
				procMacro = {
					enable = true,
				},
			},
		},
	},
	yamlls = {
		{
			yaml = {
				schemas = {
					kubernetes = "*.yaml",
					["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
					["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
					["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
					["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
				},
			},
		},
	},
	prismals = {
		single_file_support = false,
		root_dir = require("lspconfig.util").root_pattern("schema.prisma"),
		filetypes = {
			"typescript",
			"typescriptreact",
			"javascript",
			"javascriptreact",
			"json",
			"json5",
		},
	},
	templ = {},
	astro = {},
	pyright = {},
	ruff_lsp = {},
}

local efms = {
	javascript = {
		require("efmls-configs.formatters.eslint_d"),
		require("efmls-configs.formatters.prettier_d"),
		require("efmls-configs.linters.eslint_d"),
	},
	javascriptreact = {
		require("efmls-configs.formatters.eslint_d"),
		require("efmls-configs.formatters.prettier_d"),
		require("efmls-configs.linters.eslint_d"),
	},
	json = {
		require("efmls-configs.formatters.eslint_d"),
		require("efmls-configs.formatters.prettier_d"),
		require("efmls-configs.linters.eslint_d"),
	},
	proto = {
		require("efmls-configs.formatters.protolint"),
	},
	typescript = {
		require("efmls-configs.formatters.eslint_d"),
		require("efmls-configs.formatters.prettier_d"),
		require("efmls-configs.linters.eslint_d"),
	},
	typescriptreact = {
		require("efmls-configs.formatters.eslint_d"),
		require("efmls-configs.formatters.prettier_d"),
		require("efmls-configs.linters.eslint_d"),
	},
}

-- set appearances to differentiate
vim.cmd([[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]])
vim.cmd([[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]])

local border = {
	{ "▛", "FloatBorder" },
	{ "▔", "FloatBorder" },
	{ "▜", "FloatBorder" },
	{ "▕", "FloatBorder" },
	{ "▟", "FloatBorder" },
	{ "▁", "FloatBorder" },
	{ "▙", "FloatBorder" },
	{ "▏", "FloatBorder" },
}

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

	vim.keymap.set("n", "<Leader>f", function()
		Format(client.id)
	end, bufopts)

	vim.keymap.set("n", "<Leader>;", function()
		vim.diagnostic.open_float(nil, { focus = false })
	end, bufopts)

	vim.keymap.set("n", "<C-p>", vim.diagnostic.goto_prev, bufopts)
	vim.keymap.set("n", "<C-n>", vim.diagnostic.goto_next, bufopts)

	-- apperances
	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })
end

require("neodev").setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure servers are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
	automatic_installation = true,
})

mason_lspconfig.setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			single_file_support = (servers[server_name] or {}).single_file_support,
			root_dir = (servers[server_name] or {}).root_dir,
			cmd = (servers[server_name] or {}).cmd,
			settings = (servers[server_name] or {}).settings,
			filetypes = (servers[server_name] or {}).filetypes,
		})
	end,
})

-- Set gutter sign icons
local sign = function(opts)
	vim.fn.sign_define(opts.name, {
		texthl = opts.name,
		text = opts.text,
		numhl = "",
	})
end

sign({ name = "DiagnosticSignError", text = "❌" })
sign({ name = "DiagnosticSignWarn", text = "⚠️" })
sign({ name = "DiagnosticSignHint", text = "💡" })
sign({ name = "DiagnosticSignInfo", text = "ℹ️" })

-- nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete({}),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "kity" },
		{
			name = "bulma",
			option = {
				filetypes = {
					"templ",
				},
			},
		},
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
		{ name = "luasnip" },
		{ name = "path" },
	},
})

-- auto-format and lint

require("lspconfig").efm.setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		rootMarkers = { ".git/" },
		languages = efms,
	},
	init_options = {
		documentFormatting = true,
		documentRangeFormatting = true,
	},
	filetypes = vim.tbl_keys(efms),
})

-- Create an augroup that is used for managing our formatting autocmds.
--      We need one augroup per client to make sure that multiple clients
--      can attach to the same buffer without interfering with each other.
local _augroups = {}
local get_augroup = function(client)
	if not _augroups[client.id] then
		local group_name = "kickstart-lsp-format-" .. client.name
		local id = vim.api.nvim_create_augroup(group_name, { clear = true })
		_augroups[client.id] = id
	end

	return _augroups[client.id]
end

-- Whenever an LSP attaches to a buffer, we will run this function.
--
-- See `:help LspAttach` for more information about this autocmd event.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach-format", { clear = true }),
	-- This is where we attach the autoformatting for reasonable clients
	callback = function(args)
		local client_id = args.data.client_id
		local client = vim.lsp.get_client_by_id(client_id)
		local bufnr = args.buf

		-- Only attach to clients that support document formatting or we have efm configured
		if
			not client.server_capabilities.documentFormattingProvider
			and not has_value(vim.tbl_keys(efms), vim.bo.filetype)
		then
			return
		end

		-- Create an autocmd that will run *before* we save the buffer.
		--  Run the formatting command for the LSP that has just attached.
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = get_augroup(client),
			buffer = bufnr,
			callback = function()
				Format(client_id)
			end,
		})
	end,
})

function Format(client_id)
	vim.lsp.buf.format({
		filter = function(c)
			if has_value(vim.tbl_keys(efms), vim.bo.filetype) then
				return c.name == "efm"
			else
				return c.id == client_id
			end
		end,
	})
end
