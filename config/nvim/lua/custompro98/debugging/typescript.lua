-- ** Typescript debugging ** --

-- https://github.com/mxsdev/nvim-dap-vscode-js#setup
require("dap-vscode-js").setup({
    debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
    adapters = { "pwa-node" },
    -- log_file_path = "(stdpath cache)/dap_vscode_js.log",
    log_file_level = false, -- Logging level for output to file. Set to false to disable file logging.
    log_console_level = false, -- vim.log.levels.DEBUG, -- Logging level for output to console. Set to false to disable console output.
})

for _, language in ipairs({ "typescript", "javascript" }) do
    require("dap").configurations[language] = {
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
        },
    }
end
