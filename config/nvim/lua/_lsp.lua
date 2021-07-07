-- ** LSP Configuration ** --
-- named with an _ to avoid name conflicts

local nvim_lsp = require('lspconfig')

-- use on_attach to only map keybindings for lsp attaches to current buffer
local function on_attach(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- enable completion with omnifunc (<c-x><c-O>)
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- mappings
  local opts = { noremap = true, silent = true }

  -- definitions
  buf_set_keymap('n', 'gd', '<cmd>lua require"lspsaga.provider".preview_definition()<CR>', opts)
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  -- buf_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts) -- superseded by Lspsaga
  buf_set_keymap('n', 'gh', '<cmd>lua require"lspsaga.hover".render_hover_doc()<CR>', opts)
  buf_set_keymap('n', '<Leader>gh', '<cmd>lua require"lspsaga.provider".lsp_finder()<CR>', opts)
  buf_set_keymap('i', '<Leader>gh', '<cmd>lua require"lspsaga.signaturehelp".signature_help()<CR>', opts)

  -- linting
  buf_set_keymap('n', '<C-n>', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<C-p>', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)

  -- refactoring
  buf_set_keymap('n', '<Leader>rn', '<cmd>lua require"lspsaga.rename".rename()<CR>', opts)
  buf_set_keymap('n', '<Leader>ca', '<cmd>lua require"lspsaga.codeaction".code_action()<CR>', opts)
  buf_set_keymap('v', '<Leader>ca', ':<C-U>lua require("lspsaga.codeaction").range_code_action()<CR>', opts)

  if client.resolved_capabilities.document_formatting then
    vim.api.nvim_command [[augroup Format]]
    vim.api.nvim_command [[autocmd! * <buffer>]]
    vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()]]
    vim.api.nvim_command [[augroup END]]
  end
end


-- ** LSP Install ** --

local lspinstall = require('lspinstall')
lspinstall.setup()

-- loop through desired LSPs and set them up
local lsps = lspinstall.installed_servers()
for _, lsp in ipairs(lsps) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150
    }
  }
end

-- set up linters and formatters
nvim_lsp.diagnosticls.setup {
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
      eslint = {
        command = 'eslint',
        args = { '--stdin', '--stdin-filename', '%filename', '--fix-to-stdout' },
        rootPatterns = { '.git' },
      },
      prettier = {
        command = 'prettier',
        args = { '--stdin-filepath', '%filename' }
      },
    },
    formatFiletypes = {
      css = 'prettier',
      javascript = 'eslint',
      javascriptreact = 'eslint',
      json = 'prettier',
      json = 'prettier',
      less = 'prettier',
      markdown = 'prettier',
      scss = 'prettier',
      typescript = 'eslint',
      typescriptreact = 'eslint',
    }
  }
}

-- ** LSP Saga ** --
-- better UI for LSP functionality

local saga = require 'lspsaga'

saga.init_lsp_saga {
  error_sign = '❌',
  warn_sign = '⚠️',
  hint_sign = '⁉️',
  infor_sign = 'ℹ️',
  border_style = 'round',

  finder_action_keys = {
    open = 'o',
    vsplit = 'v',
    split = 'x',
    quit = 'q',
  }
}
