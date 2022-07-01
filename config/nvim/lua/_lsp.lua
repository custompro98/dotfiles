-- ** LSP Configuration ** --
-- named with an _ to avoid name conflicts

local vim = vim
local cmd = vim.cmd

-- set appearances to reduce dependency on Lspsaga
vim.cmd [[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]]
vim.cmd [[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]

local border = {
      {"▛", "FloatBorder"},
      {"▔", "FloatBorder"},
      {"▜", "FloatBorder"},
      {"▕", "FloatBorder"},
      {"▟", "FloatBorder"},
      {"▁", "FloatBorder"},
      {"▙", "FloatBorder"},
      {"▏", "FloatBorder"},
}

-- use on_attach to only map keybindings for lsp attaches to current buffer
local function on_attach(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- enable completion with omnifunc (<c-x><c-O>)
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- mappings
  local opts = { noremap = true, silent = true }

  -- definitions
  buf_set_keymap('n', 'gd', '<cmd>Lspsaga preview_definition<CR>', opts)
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gf', '<cmd>lua vim.lsp.buf.formatting_seq_sync()<CR>', opts)
  -- buf_set_keymap('i', '<Leader>gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('i', '<Leader>gh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  -- linting
  buf_set_keymap('n', '<C-n>', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<C-p>', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)

  -- refactoring
  buf_set_keymap('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)


  -- apperances
  vim.lsp.handlers["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border})
  vim.lsp.handlers["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border})

  -- autoformat
  if client.resolved_capabilities.document_formatting and client.name ~= 'intelephense' then
    vim.api.nvim_exec([[
      augroup Format
      autocmd! * <buffer>
      autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()
      augroup end
    ]], false)
  end
end

-- ** LSP Install ** --
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspinstall = require("nvim-lsp-installer")
local lspconfig = require("lspconfig")
local servers = require('nvim-lsp-installer.servers')

local lsps = {
  [1] = 'dockerls',
  [2] = 'gopls',
  [3] = 'sumneko_lua',
  [4] = 'intelephense',
  [5] = 'terraformls',
  [6] = 'tsserver',
  [7] = 'diagnosticls',
  [8] = 'denols',
}

lspinstall.setup({
  -- automatic_installation = true, -- debug this, causing an error but 🤷
  ui = {
    icons = {
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗"
    }
  },
})

for _, lsp in ipairs(lsps) do
  local opts = {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = capabilities,
  }

  if lsp == 'sumneko_lua' then
    opts.settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' }
        }
      }
    }
  end

  if lsp == 'tsserver' then
    opts.root_dir = lspconfig.util.root_pattern("package.json")
  end

  if lsp == 'denols' then
    opts.root_dir = lspconfig.util.root_pattern("deno.json")
  end

  if lsp == 'diagnosticls' then
    opts.filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }

    opts.init_options = {
      linters = {
        eslint = {
          command = 'eslint',
          rootPatterns = { '.git' },
          debounce = 100,
          args = { '--stdin', '--stdin-filename', '%filepath', '--format', 'json' },
          sourceName = 'eslint',
          parseJson = {
            errorsRoot = '[0].messages',
            line = 'line',
            column = 'column',
            endLine = 'endLine',
            endColumn = 'endColumn',
            message = '[eslint] ${message} [${ruleId}]',
            security = 'severity'
          },
          securities = {
            [2] = 'error',
            [1] = 'warning'
          }
        },
      },
      formatters = {
        prettier = {
          command = 'prettier',
          args = { '--stdin-filepath', '%filename' },
          rootPatterns = { '.git' },
        },
      },
      formatFiletypes = {
        css = 'prettier',
        javascript = 'prettier',
        javascriptreact = 'prettier',
        json = 'prettier',
        less = 'prettier',
        markdown = 'prettier',
        scss = 'prettier',
        typescript = 'prettier',
        typescriptreact = 'prettier',
      },
    }
  end

  lspconfig[lsp].setup{opts}
end

cmd [[augroup lsp]]
cmd [[au!]]
cmd [[au FileType scala,sbt lua require('metals').initialize_or_attach({})]]
cmd [[augroup end]]

local signs = { Error = "❌", Warn = "⚠️", Hint = "⁉️", Info = "ℹ️" }

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
