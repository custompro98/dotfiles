-- ** DAP ** --
local utils = require("custompro98.plugins.utils")

-- Debug adapters (debugpy, js-debug-adapter) are installed by Mason, see lsp.lua
vim.pack.add({
	utils.gh("mfussenegger/nvim-dap"),
	utils.gh("nvim-neotest/nvim-nio"),
	utils.gh("rcarriga/nvim-dap-ui"),
	utils.gh("mfussenegger/nvim-dap-python"),
})

local dap = require("dap")
local dapui = require("dapui")

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
				{ id = "repl", size = 0.75 },
				{ id = "breakpoints", size = 0.25 },
			},
			position = "bottom",
			size = 15,
		},
	},
})

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

-- ** Python ** --

-- Runs the program with the project's python (VIRTUAL_ENV or .venv), debugpy itself comes from Mason
require("dap-python").setup("debugpy-adapter")

-- ** TypeScript / JavaScript ** --

dap.adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "js-debug-adapter",
		args = { "${port}" },
	},
}

-- Allow `"type": "node"` in .vscode/launch.json, which nvim-dap loads automatically
dap.adapters["node"] = function(cb, config)
	if config.type == "node" then
		config.type = "pwa-node"
	end
	cb(dap.adapters["pwa-node"])
end

for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
	dap.configurations[language] = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			skipFiles = { "<node_internals>/**", "**/node_modules/**" },
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach to process",
			processId = function()
				return require("dap.utils").pick_process({ filter = "node" })
			end,
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			skipFiles = { "<node_internals>/**", "**/node_modules/**" },
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach to :9229 (--inspect)",
			port = 9229,
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			skipFiles = { "<node_internals>/**", "**/node_modules/**" },
		},
	}
end

-- ** Keymaps ** --

local map = function(keys, func, desc, mode)
	vim.keymap.set(mode or "n", keys, func, { desc = "DAP: " .. desc })
end

map("<Leader>ds", dap.continue, "Start")
map("<Leader>dc", dap.continue, "Continue")
map("<Leader>dR", dap.run_to_cursor, "Run to Cursor")
map("<Leader>dt", dap.toggle_breakpoint, "Toggle Breakpoint")
map("<Leader>dT", function()
	dap.set_breakpoint(vim.fn.input("[Condition] > "))
end, "Conditional Breakpoint")
map("<Leader>di", dap.step_into, "Step Into")
map("<Leader>do", dap.step_over, "Step Over")
map("<Leader>du", dap.step_out, "Step Out")
map("<Leader>db", dap.step_back, "Step Back")
map("<Leader>dp", dap.pause, "Pause")
map("<Leader>dd", dap.disconnect, "Disconnect")
map("<Leader>dx", dap.terminate, "Terminate")
map("<Leader>dq", dap.close, "Quit")
map("<Leader>dr", dap.repl.toggle, "Toggle REPL")
map("<Leader>dU", dapui.toggle, "Toggle UI")
map("<Leader>de", dapui.eval, "Evaluate", { "n", "v" })
map("<Leader>dE", function()
	dapui.eval(vim.fn.input("[Expression] > "))
end, "Evaluate Input")
map("<Leader>dh", function()
	require("dap.ui.widgets").hover()
end, "Hover Variables")
map("<Leader>dS", function()
	require("dap.ui.widgets").centered_float(require("dap.ui.widgets").scopes)
end, "Scopes")
