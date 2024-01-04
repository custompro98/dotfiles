-- ** Typescript debugging ** --

-- https://github.com/mxsdev/nvim-dap-vscode-js#setup
for _, language in ipairs({ "typescript", "javascript" }) do
    require("dap").configurations[language] = {
        {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = function()
                require("dap.utils").pick_process({ filter = "sway" })
            end,
            cwd = "${workspaceFolder}",
        },
    }
end
