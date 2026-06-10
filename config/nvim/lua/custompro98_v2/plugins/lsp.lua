-- ** LSP ** --
local utils = require("custompro98_v2.plugins.utils")

local tooling_by_ft = {
	blade = {
		form = { "pint" },
		lint = {},
	},
	lua = {
		form = { "stylua" },
		lint = {},
	},
	php = {
		form = { "pint" },
		lint = { "phpstan" },
	},
	python = {
		form = { "ruff" },
		lint = { "ruff" },
	},
	ruby = {
		form = { "rubocop" },
		lint = { "rubocop" },
	},
	eruby = {
		form = { "erb-formatter" },
		lint = {},
	},
	typescript = {
		form = { "prettierd", "biome" },
		lint = {},
	},
}

---@param client vim.lsp.Client
local function disable_formatting(client)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

-- Enable the following language servers
---@type table<string, vim.lsp.Config>
local servers = {
	biome = {
		on_attach = function(client)
			disable_formatting(client)
		end,
		root_markers = { "biome.json", "biome.jsonc" },
	},
	buf_ls = {},
	cssls = {
		filetypes = { "css", "html", "htmldjango", "eruby", "javascriptreact", "typescriptreact" },
	},
	eslint = {},
	gh_actions_ls = {},
	gopls = {},
	html = {},
	intelephense = {
		filetypes = { "blade", "php" },
	},
	lua_ls = {
		on_init = function(client)
			disable_formatting(client)

			if client.workspace_folders then
				local path = client.workspace_folders[1].name
				if
					path ~= vim.fn.stdpath("config")
					and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
				then
					return
				end
			end

			client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
				runtime = {
					version = "LuaJIT",
					path = { "lua/?.lua", "lua/?/init.lua" },
				},
				workspace = {
					checkThirdParty = false,
					-- NOTE: this is a lot slower and will cause issues when working on your own configuration.
					--  See https://github.com/neovim/nvim-lspconfig/issues/3189
					library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
						"${3rd}/luv/library",
						"${3rd}/busted/library",
					}),
				},
			})
		end,
		---@type lspconfig.settings.lua_ls
		settings = {
			Lua = {
				format = { enable = false }, -- Disable formatting (formatting is done by stylua)
			},
		},
	},
	pyright = {
		on_attach = function(client)
			disable_formatting(client)
		end,
	},
	ruby_lsp = {
		on_attach = function(client)
			disable_formatting(client)
		end,
	},
	ruff = {},
	tailwindcss = {
		on_attach = function(client)
			disable_formatting(client)
		end,
		settings = {
			tailwindCSS = {
				["includeLanguages"] = { ["eruby"] = "erb" },
				experimental = {
					classRegex = {
						[[class= "([^"]*)]],
						[[class: "([^"]*)]],
						[[class\("([^"]*)"\)]],
					},
				},
			},
		},
	},
	templ = {},
	ts_ls = {
		on_attach = function(client)
			-- Disable ts_ls formatting if Prettier or Biome is installed/configured in the project
			local root_dir = client.config.root_dir
			local has_prettier = vim.fs.find({
				".prettierrc",
				".prettierrc.json",
				".prettierrc.yaml",
				".prettierrc.yml",
				".prettierrc.js",
				"prettier.config.js",
			}, { path = root_dir, upward = true })[1]
			local has_biome = vim.fs.find({ "biome.json", "biome.jsonc" }, { path = root_dir, upward = true })[1]

			if has_prettier or has_biome then
				disable_formatting(client)
			end
		end,
		root_markers = { "package.json" },
	},
}

-- Useful status updates for LSP.
vim.pack.add({ utils.gh("j-hui/fidget.nvim") })
require("fidget").setup({})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("<Leader>gh", vim.lsp.buf.signature_help, "[G]oto [H]over")
		map("gh", vim.lsp.buf.hover, "[G]oto [H]over")

		map("<Leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("<Leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

		-- WARN: This is not Goto Definition, this is Goto Declaration.
		--  For example, in C this would take you to the header.
		map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- The following two autocommands are used to highlight references of the
		-- word under your cursor when your cursor rests there for a little while.
		--    See `:help CursorHold` for information about when this is executed
		--
		-- When you move your cursor, the highlights will be cleared (the second autocommand).
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method("textDocument/documentHighlight", event.buf) then
			local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
				end,
			})
		end

		-- The following code creates a keymap to toggle inlay hints in your
		-- code, if the language server you are using supports them
		--
		-- This may be unwanted, since they displace some of your code
		if client and client:supports_method("textDocument/inlayHint", event.buf) then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[T]oggle Inlay [H]ints")
		end
	end,
})
vim.pack.add({
	utils.gh("neovim/nvim-lspconfig"),
	utils.gh("mason-org/mason.nvim"),
	utils.gh("mason-org/mason-lspconfig.nvim"),
	utils.gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
})

-- Automatically install LSPs and related tools to stdpath for Neovim
require("mason").setup({})

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, utils.all_tools(tooling_by_ft))

require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

-- Configure LSP servers
for name, server in pairs(servers) do
	vim.lsp.config(name, server)
	vim.lsp.enable(name)
end

-- gleam is not managed by Mason, configure and enable manually
vim.lsp.config("gleam", {})
vim.lsp.enable("gleam")

-- ** Formatting ** --

vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		if tooling_by_ft[vim.bo[bufnr].filetype].form then
			return { timeout_ms = 500 }
		else
			return nil
		end
	end,
	default_format_opts = {
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		astro = tooling_by_ft["typescript"].form,
		blade = tooling_by_ft["blade"].form,
		eruby = tooling_by_ft["eruby"].form,
		go = { "gofmt" }, -- gofmt is not managed by mason
		javascript = tooling_by_ft["typescript"].form,
		javascriptreact = tooling_by_ft["typescript"].form,
		json = tooling_by_ft["typescript"].form,
		json5 = tooling_by_ft["typescript"].form,
		lua = tooling_by_ft["lua"].form,
		php = tooling_by_ft["php"].form,
		python = tooling_by_ft["python"].form,
		ruby = tooling_by_ft["ruby"].form,
		templ = { "templ" }, -- templ is not managed by mason
		typescript = tooling_by_ft["typescript"].form,
		typescriptreact = tooling_by_ft["typescript"].form,
	},
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true })
end, { desc = "[F]ormat buffer" })

-- ** Linting ** --

vim.pack.add({ utils.gh("mfussenegger/nvim-lint") })
local lint = require("lint")
lint.linters_by_ft = {
	php = tooling_by_ft["php"].lint,
	python = tooling_by_ft["python"].lint,
	ruby = tooling_by_ft["ruby"].lint,
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("lint", { clear = true }),
	callback = function()
		-- Only run the linter in buffers that you can modify in order to
		-- avoid superfluous noise, notably within the handy LSP pop-ups that
		-- describe the hovered symbol using Markdown.
		if vim.bo.modifiable then
			lint.try_lint()
		end
	end,
})
