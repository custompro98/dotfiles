local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Completion ** --

-- autopairs
require('nvim-autopairs').setup({
  check_ts = true,
  ts_config = {
    lua = {'string'},-- it will not add pair on that treesitter node
    javascript = {'template_string'},
    java = false,-- don't check treesitter on java
  }
})

require("nvim-autopairs.completion.compe").setup({
  map_cr = true, --  map <CR> on insert mode
  map_complete = true -- it will auto insert `(` after select function or method item
})

-- enables comple support
opt.completeopt = 'menu,menuone,noselect'

require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = true;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  allow_prefix_unmatch = false;

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
  };
}

local opts = { silent = true, expr = true, noremap = true }

api.nvim_set_keymap('i', '<C-Space>', 'compe#complete()', opts)
-- disabled in favor of nvim-autopairs.completion.compe.map_cr
-- api.nvim_set_keymap('i', '<CR>', 'pumvisible() ? compe#confirm({ "keys": "<CR>", "select": v:true }) : "<CR>"', opts)
api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", opts)
api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", opts)
api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", opts)
api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", opts)

-- provided by https://github.com/hrsh7th/nvim-compe#how-to-use-tab-to-navigate-completion-menu
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  -- elseif vim.fn['vsnip#available'](1) == 1 then
    -- return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  -- elseif vim.fn['vsnip#jumpable'](-1) == 1 then
    -- return t "<Plug>(vsnip-jump-prev)"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end
