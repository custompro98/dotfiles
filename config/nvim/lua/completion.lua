local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Completion ** --

-- enables cmp support
opt.completeopt = 'menu,menuone,noselect'

local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-y>'] = cmp.config.disable, -- If you want to remove the default `<C-y>` mapping, You can specify `cmp.config.disable` value.
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- disabled in favor of nvim-autopairs
  },
  sources = cmp.config.sources(
    {
      { name = 'nvim_lsp' },
      { name = 'cmp_tabnine' },
      { name = 'nvim_lua' },
      { name = 'vsnip' },
    },
    {
      {
        name = 'buffer',
        opts = {
          get_bufnrs = function()
            return vim.api.nvim_list_bufs()
          end
        }
      },
      { name = 'path' },
      { name = 'emoji' },
    }
  )
})

-- autopairs
require('nvim-autopairs').setup({
  check_ts = true,
  ts_config = {
    lua = {'string'},-- it will not add pair on that treesitter node
    javascript = {'template_string'},
    java = false,-- don't check treesitter on java
  }
})

-- tabnine
local tabnine = require('cmp_tabnine.config')
tabnine:setup({
  max_lines = 1000;
  max_num_results = 20;
  sort = true;
  run_on_every_keystroke = true;
  snippet_placeholder = '..';
})
