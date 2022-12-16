local vim = vim

local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  "dockerls",
  "gopls",
  "sumneko_lua",
  "terraformls",
  "tailwindcss",
  "tsserver",
  "graphql",
  "bufls",
  "prismals",
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

local null_sources = require("null-ls.sources")

lsp.on_attach(function(client, bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
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
  vim.keymap.set("n", "<Leader>f", vim.lsp.buf.format, bufopts)
  vim.keymap.set("n", "<Leader>;", function()
    vim.diagnostic.open_float(nil, { focus = false })
  end, bufopts)

  vim.keymap.set("n", "<C-p>", vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set("n", "<C-n>", vim.diagnostic.goto_next, bufopts)

  -- capabilities overrides
  if client.server_capabilities.documentFormattingProvider then
    -- if null-ls is available, use it
    if null_sources.get_available(filetype) then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    local auformat = vim.api.nvim_create_augroup("custompro98-autoformat", {})
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
      group = auformat,
      pattern = "* <buffer>",
      callback = vim.lsp.buf.format,
    })
  end
end)

-- auto-format and lint
local null_ls = require("null-ls")
local null_opts = lsp.build_options("null-ls", {})

null_ls.setup({
  on_attach = null_opts.on_attach,
  sources = {
    -- diagnostics
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.protolint,
    -- code_actions
    null_ls.builtins.code_actions.eslint,
    -- formatting
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.rustywind,
    null_ls.builtins.formatting.gofmt,
    null_ls.builtins.formatting.goimports,
    null_ls.builtins.formatting.terraform_fmt,
    null_ls.builtins.formatting.protolint,
    null_ls.builtins.formatting.stylua,
  },
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
