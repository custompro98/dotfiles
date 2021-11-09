-- ** LSP Configuration ** --
-- named with an _ to avoid name conflicts

local vim = vim
local cmd = vim.cmd

local nvim_lsp = require('lspconfig')

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
  buf_set_keymap('i', '<Leader>gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

  -- linting
  buf_set_keymap('n', '<C-n>', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<C-p>', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)

  -- refactoring
  buf_set_keymap('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)


  -- apperances
  vim.lsp.handlers["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border})
  vim.lsp.handlers["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border})

  -- autoformat
  if client.resolved_capabilities.document_formatting and client.name ~= 'php' then
    vim.api.nvim_exec([[
      augroup Format
      autocmd! * <buffer>
      autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()
      augroup end
    ]], false)
  end
end

-- ** LSP Install ** --
local lsps = {
  [1] = 'dockerfile',
  [2] = 'go',
  [3] = 'lua',
  [4] = 'php',
  [5] = 'terraform',
  [6] = 'typescript',
  [7] = 'diagnosticls',
}

local lspinstall = require('lspinstall')
lspinstall.setup()

-- add cmp capabilities
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- loop through desired LSPs and set them up
for _, lsp in ipairs(lsps) do
  if not nvim_lsp[lsp] then
    lspinstall.install_server(lsp)
  end

  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150
    },
    capabilities = capabilities,
  }
end

if nvim_lsp['terraform'] then
  -- terraform needs an extra filetype
  nvim_lsp['terraform'].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150
    },
    filetypes = { "terraform", "tf" }
  }
end

if nvim_lsp['lua'] then
  nvim_lsp['lua'].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150
    },
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' }
        }
      }
    }
  }
end

if nvim_lsp['diagnosticls'] then
  nvim_lsp['diagnosticls'].setup {
    on_attach = on_attach,
    filetypes = { 'javascript', 'javascriptreact', 'json', 'typescript', 'typescriptreact', 'css', 'scss', 'markdown' },
    init_options = {
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
      filetypes = {
        javascript = 'eslint',
        javascriptreact = 'eslint',
        typescript = 'eslint',
        typescriptreact = 'eslint',
      },
      formatters = {
        -- eslint = {
        --   command = 'eslint',
        --   args = { '--stdin', '--stdin-filename', '%filename', '--fix-to-stdout' },
        --   rootPatterns = { '.git' },
        -- },
        prettier = {
          command = 'prettier',
          args = { '--stdin-filepath', '%filename' }
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
      }
    }
  }
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

-- ** Diagnostics ** --
-- print out all installed lsp servers
function LspListInstalled()
  for _, lsp in ipairs(require('lspinstall').installed_servers()) do
    print(lsp)
  end
end

cmd [[command! LspListInstalled lua LspListInstalled()]]
