-- ** LSP Configuration ** --
-- named with an _ to avoid name conflicts

local vim = vim

local lsps = {
  'dockerls',
  'gopls',
  'sumneko_lua',
  'terraformls',
  'tailwindcss',
  'tsserver',
  'graphql',
  'bufls',
}

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = lsps
})

vim.cmd [[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]]
vim.cmd [[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]

-- auto-format and lint
local null_ls = require('null-ls')
local null_sources = require('null-ls.sources')

null_ls.setup({
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
  }
})

local on_attach = function(client, bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  vim.diagnostic.config({ virtual_text = false })

  -- mapping
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('i', '<Leader>gh', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<Leader>f', vim.lsp.buf.format, bufopts)
  vim.keymap.set('n', '<Leader>;', ':lua vim.diagnostic.open_float(nil, { focus = false })<CR>', bufopts)

  vim.keymap.set('n', '<C-p>', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', '<C-n>', vim.diagnostic.goto_next, bufopts)

  -- capabilities overrides
  if client.server_capabilities.documentFormattingProvider then
    -- if null-ls is available, use it
    if null_sources.get_available(filetype) then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    vim.api.nvim_exec([[
      augroup Format
      autocmd! * <buffer>
      autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
      augroup end
    ]], false)
  end
end

local lsp_flags = {
  debounce_text_changes = 150,
}

local nvim_lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

for _, lsp in pairs(lsps) do
  local opts = {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
  }

  if lsp == 'sumneko_lua' then
    opts.settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim ' }
        }
      }
    }
  end

  nvim_lsp[lsp].setup(opts)
end
