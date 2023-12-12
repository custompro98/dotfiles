-- ** Typescript debugging ** --

-- https://github.com/mxsdev/nvim-dap-vscode-js#setup
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
