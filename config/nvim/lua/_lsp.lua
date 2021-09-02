-- ** LSP Configuration ** --
-- named with an _ to avoid name conflicts

local vim = vim
local cmd = vim.cmd

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
  buf_set_keymap('n', 'gh', '<cmd>lua require"lspsaga.hover".render_hover_doc()<CR>', opts)
  buf_set_keymap('i', '<Leader>gh', '<cmd>lua require"lspsaga.signaturehelp".signature_help()<CR>', opts)

  -- linting
  buf_set_keymap('n', '<C-n>', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<C-p>', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)

  -- refactoring
  buf_set_keymap('n', '<Leader>rn', '<cmd>lua require"lspsaga.rename".rename()<CR>', opts)
  buf_set_keymap('n', '<Leader>ca', '<cmd>lua require"lspsaga.codeaction".code_action()<CR>', opts)
  buf_set_keymap('v', '<Leader>ca', ':<C-U>lua require("lspsaga.codeaction").range_code_action()<CR>', opts)
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

-- terraform needs an extra filetype
nvim_lsp['terraform'].setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150
  },
  filetypes = { "terraform", "tf" }
}

cmd [[augroup lsp]]
cmd [[au!]]
cmd [[au FileType scala,sbt lua require('metals').initialize_or_attach({})]]
cmd [[augroup end]]

-- set up linters and formatters

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

-- ** Diagnostics ** --
-- print out all installed lsp servers
function LspListInstalled()
  for _, lsp in ipairs(require('lspinstall').installed_servers()) do
    print(lsp)
  end
end

cmd [[command! LspListInstalled lua LspListInstalled()]]
