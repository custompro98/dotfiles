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
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-y>'] = cmp.config.disable, -- If you want to remove the default `<C-y>` mapping, You can specify `cmp.config.disable` value.
    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- disabled in favor of nvim-autopairs
  }),
  sources = cmp.config.sources(
    {
      { name = 'kitty'},
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
      { name = 'vsnip' },
    },
    {
      {
        name = 'buffer',
        options = {
          get_bufnrs = function()
            return vim.api.nvim_list_bufs()
          end
        }
      },
      { name = 'path' },
    }
  )
})

cmp.setup.cmdline ({
  mapping = cmp.mapping.preset.cmdline({})
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
require('nvim-ts-autotag').setup()

-- vsnip
vim.g['vsnip_snippet_dir'] = '~/.config/nvim/vsnip'

vim.cmd([[
  imap <expr> <C-n> vsnip#available(1)   ? '<Plug>(vsnip-expand-or-jump)' : '<C-n>'
  smap <expr> <C-n> vsnip#available(1)   ? '<Plug>(vsnip-expand-or-jump)' : '<C-n>'
  imap <expr> <C-p> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)' : '<C-p>'
  smap <expr> <C-p> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)' : '<C-p>'
]])

api.nvim_set_keymap('v', '<Leader>vc', '<Plug>(vsnip-select-text)<Esc>', {})
api.nvim_set_keymap('v', '<Leader>vx', '<Plug>(vsnip-cut-text)<Esc>', {})
