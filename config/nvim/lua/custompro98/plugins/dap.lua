-- ** DAP ** --

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{ "rcarriga/nvim-dap-ui", opts = {} },
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
			-- Typescript
			-- https://github.com/mxsdev/nvim-dap-vscode-js#setup
			{
				"microsoft/vscode-js-debug",
				build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
			},
			{
				"mxsdev/nvim-dap-vscode-js",
				opts = {
					debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
					adapters = { "pwa-node" },
					-- log_file_path = "(stdpath cache)/dap_vscode_js.log",
					log_file_level = false, -- Logging level for output to file. Set to false to disable file logging.
					log_console_level = false, -- vim.log.levels.DEBUG, -- Logging level for output to console. Set to false to disable console output.
				},
			},
			"nvim-neotest/nvim-nio",
		},
		keys = {
			{
				"<leader>dR",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Run to Cursor",
			},
			{
				"<leader>dE",
				function()
					require("dapui").eval(vim.fn.input("[Expression] > "))
				end,
				desc = "Evaluate Input",
			},
			{
				"<leader>dT",
				function()
					require("dap").set_breakpoint(vim.fn.input("[Condition] > "))
				end,
				desc = "Conditional Breakpoint",
			},
			{
				"<leader>dU",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle UI",
			},
			{
				"<leader>db",
				function()
					require("dap").step_back()
				end,
				desc = "Step Back",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue",
			},
			{
				"<leader>dd",
				function()
					require("dap").disconnect()
				end,
				desc = "Disconnect",
			},
			{
				"<leader>de",
				function()
					require("dapui").eval()
				end,
				mode = { "n", "v" },
				desc = "Evaluate",
			},
			{
				"<leader>dg",
				function()
					require("dap").session()
				end,
				desc = "Get Session",
			},
			{
				"<leader>dh",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Hover Variables",
			},
			{
				"<leader>dS",
				function()
					require("dap.ui.widgets").scopes()
				end,
				desc = "Scopes",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
			},
			{
				"<leader>dp",
				function()
					require("dap").pause.toggle()
				end,
				desc = "Pause",
			},
			{
				"<leader>dq",
				function()
					require("dap").close()
				end,
				desc = "Quit",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Toggle REPL",
			},
			{
				"<leader>ds",
				function()
					require("dap").continue()
				end,
				desc = "Start",
			},
			{
				"<leader>dt",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			},
			{
				"<leader>dT",
				function()
					require("dap").set_breakpoint(vim.fn.input("[Condition] > "))
				end,
				desc = "Conditional Breakpoint",
			},
			{
				"<leader>dx",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
			{
				"<leader>du",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			require("mason-nvim-dap").setup({
				automatic_setup = true,
				handlers = {},
				ensure_installed = {},
			})

			dapui.setup({
				icons = {
					expanded = "▾",
					collapsed = "▸",
					current_frame = "*",
				},
				controls = {
					icons = {
						pause = "⏸",
						play = "▶",
						step_into = "⏎",
						step_over = "⏭",
						step_out = "⏮",
						step_back = "b",
						run_last = "▶▶",
						terminate = "⏹",
						disconnect = "⏏",
					},
				},
				layouts = {
					{
						elements = {
							{
								id = "repl",
								size = 0.75,
							},
							{
								id = "breakpoints",
								size = 0.25,
							},
						},
						position = "bottom",
						size = 15,
					},
				},
			})

			dap.listeners.after.event_initialized["dapui_config"] = dapui.open
			dap.listeners.before.event_terminated["dapui_config"] = dapui.close
			dap.listeners.before.event_exited["dapui_config"] = dapui.close

			require("custompro98.debugging.typescript")
		end,
	},
}
