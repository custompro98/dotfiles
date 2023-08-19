local vim = vim

local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  "dockerls",
  "gopls",
  "lua_ls",
  "terraformls",
  "tailwindcss",
  "tsserver",
  "graphql",
  "bufls",
  "prismals",
  "rust_analyzer",
  "yamlls",
  "denols",
})

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mapping = lsp.defaults.cmp_mappings({
  ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
  ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
  ["<C-y>"] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})
local cmp_sources = lsp.defaults.cmp_sources()
table.insert(cmp_sources, {
  { name = "kity" },
  { name = "nvim_lsp" },
  { name = "nvim_lua" },
  { name = "luasnip" },
  { name = "path" },
})

lsp.setup_nvim_cmp({
  mapping = cmp_mapping,
  sources = cmp_sources,
})

lsp.set_preferences({
  suggest_lsp_servers = false,
  sign_icons = {
    error = "❌",
    warn = "⚠️",
    hint = "💡",
    info = "ℹ️",
  },
})

lsp.nvim_workspace()

vim.diagnostic.config({
  virtual_text = true,
})

lsp.on_attach(function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  vim.diagnostic.config({ virtual_text = false })

  -- mapping
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "gh", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("i", "<Leader>gh", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "<Leader>D", vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
  vim.keymap.set("n", "<Leader>f", function ()
    vim.lsp.buf.format({ filter = function (c)
      return c.name == "null-ls"
    end })
  end, bufopts)
  vim.keymap.set("n", "<Leader>;", function()
    vim.diagnostic.open_float(nil, { focus = false })
  end, bufopts)

  vim.keymap.set("n", "<C-p>", vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set("n", "<C-n>", vim.diagnostic.goto_next, bufopts)
end)

lsp.configure('rust_analyzer', {
  cmd = {
    "rustup", "run", "stable", "rust-analyzer",
  },
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
        enable = true
      },
    }
  },
})

-- auto-format and lint
local null_ls = require("null-ls")
local null_opts = lsp.build_options("null-ls", {})

null_ls.setup({
  on_attach = null_opts.on_attach,
  debug = true,
  sources = {
    -- diagnostics
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.protolint,
    -- code_actions
    null_ls.builtins.code_actions.eslint,
    -- formatting
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.gofmt,
    null_ls.builtins.formatting.goimports,
    null_ls.builtins.formatting.terraform_fmt,
    null_ls.builtins.formatting.protolint,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.rustfmt,
  },
})

lsp.configure('yamlls', {
  settings = {
    yaml = {
      schemas = {
        -- kubernetes = "*.yaml",
        ["https://raw.githubusercontent.com/argoproj/argo-schema-generator/main/schema/argo_all_k8s_kustomize_schema.json"] = "{dev,prod}/**/*.yaml",
        ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
        ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
        ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
        ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
      }
    }
  }
})

lsp.configure('tsserver', {
  single_file_support = false,
  root_dir = require('lspconfig.util').root_pattern('package.json')
})

lsp.configure('denols', {
  single_file_support = false,
  root_dir = require('lspconfig.util').root_pattern('deno.json', 'deno.jsonc')
})

lsp.configure('tailwindcss', {
  root_dir = require('lspconfig.util').root_pattern('tailwind.config.js', 'tailwind.config.ts', 'twind.config.ts')
})

lsp.setup()

-- autopairs
require("nvim-autopairs").setup({
  check_ts = true,
  ts_config = {
    lua = { "string" }, -- it will not add pair on that treesitter node
    javascript = { "template_string" },
    java = false, -- don"t check treesitter on java
  },
})
require("nvim-ts-autotag").setup()

-- ai.vim
vim.keymap.set("n", "<Leader>ai", ":AI ", {})
vim.keymap.set("v", "<Leader>ai", ":AI ", {})
vim.keymap.set("i", "<Leader>ai", "<Esc>:AI<CR>a", {})
