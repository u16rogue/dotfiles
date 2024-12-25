-- Auto-install & setup lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath})
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

vim.opt.tabstop        = 2
vim.opt.softtabstop    = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true

--vim.opt.autoindent     = true
--vim.opt.copyindent     = true

vim.opt.cmdheight      = 0
vim.o.laststatus       = 3 -- keep status line at the bottom
vim.opt.showmode       = false
vim.opt.signcolumn     = 'yes'
vim.wo.wrap            = true
vim.opt.number         = true
vim.opt.showcmd        = true
vim.opt.wildmenu       = true
vim.opt.showmatch      = true
vim.opt.termguicolors  = true
vim.opt.linebreak      = true
vim.opt.pumheight      = 10
vim.opt.relativenumber = true

vim.opt.clipboard      = 'unnamedplus'

vim.opt.ignorecase     = true
vim.opt.smartcase      = true
-- vim.opt.hlsearch       = false

-- file undo history
vim.opt.undofile       = true

-- whitespace visualization
vim.opt.list           = true
vim.opt.listchars:append 'space:⋅'
vim.opt.listchars:append 'eol:↴'
vim.o.pumblend = 0
vim.o.winblend = 0

-- Press enter to insert newline
vim.keymap.set('n', '<cr>', 'o<esc>', { silent = true })

vim.api.nvim_create_autocmd('RecordingEnter', { callback = function() vim.o.cmdheight = 1 end })
vim.api.nvim_create_autocmd('RecordingLeave', { callback = function() vim.o.cmdheight = 0 end })

local lazy = require('lazy')
lazy.setup({
  -- Look & feel
  { 'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      require('catppuccin').setup({
        --transparent_background = true,
        flavour = 'mocha',
        styles = {
          --comments = {},
        },
      })
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  -- Tabs and Buffers
  'romgrk/barbar.nvim',

  -- Status line
  { 'nvim-lualine/lualine.nvim',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', opt = true },
    },
    opts = {
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {{
          'filename',
          path = 3,
        }},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {
        lualine_c = {'filename'},
        lualine_x = {'location'},
      },
    },
  },

  -- Directory Tree
  { 'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      renderer = { group_empty = true, indent_width = 2, indent_markers = { enable = true, inline_arrows = false } }, 
      git = { ignore = false },
      view = { number = true, float = { enable = true, open_win_config = { width = 80, height = 100 } } },
      filters = { dotfiles = false },
    },
  },

  -- Tree-sitter
  { 'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },
  { 'nvim-treesitter/nvim-treesitter-context', opts = {} },

  -- Scope Highlighter
  { 'HiPhish/rainbow-delimiters.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },

  -- Telescope
  { 'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        -- Only load if `make` is installed
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
    },
  },

  -- Git signs
  { 'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and vim-fugitive keymaps
        vim.keymap.set({'n', 'v'}, ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
        vim.keymap.set({'n', 'v'}, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
      end,
    },
  },

  -- Indentation visuals
  { 'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
  },

  -- [[ MASON + NVIM-LSP ]] --
  { 'williamboman/mason.nvim',
    config = true,
    build = ':MasonUpdate',
  },
  
  'williamboman/mason-lspconfig.nvim',
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',
  'L3MON4D3/LuaSnip',
  'saadparwaiz1/cmp_luasnip',
  'p00f/clangd_extensions.nvim',

  -- [[ COC ]] --
  -- { 'neoclide/coc.nvim', branch = 'release' },

  -- Integration Development
  'skywind3000/asyncrun.vim',

  -- Debugging
  'mfussenegger/nvim-dap',
  'nvim-neotest/nvim-nio',
  { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },
  'theHamsta/nvim-dap-virtual-text',

  -- 'ryanoasis/vim-devicons',
  'tpope/vim-ragtag',

  -- Language
  'sheerun/vim-polyglot',
  'leafOfTree/vim-svelte-plugin',
  'ziglang/zig.vim',
  'bfrg/vim-cpp-modern',

  -- Multi-case, regex replace
  'tpope/vim-abolish',

  -- Align plugin
  'junegunn/vim-easy-align',

  -- Scope splitter / joiner
  {
    'Wansmer/treesj',
    -- keys = { '<space>m', '<space>j', '<space>s' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesj').setup({ use_default_keymaps = false })
    end,
  },

})

-- Config (n)Vim
vim.cmd [[highlight LineNr guifg=#fff]]

-- Easy align
vim.keymap.set('x', '<leader>aa', '<plug>(EasyAlign)', { silent = true }) -- align align
--vim.keymap.set('n', 'ga', '<plug>(EasyAlign)', { silent = true })

-- Scope split
vim.keymap.set('n', '<leader>as', '<Cmd>TSJToggle<CR>', { silent = true }) -- align scope


vim.diagnostic.config({
  -- virtual_text = false,
  update_in_insert = false,
  severity_sort = true,
  checkCurrentLine = true,
  virtualTextCurrentLineOnly = true,
})
vim.o.updatetime = 250
-- vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

-- Config vim-cpp-modern
vim.g.cpp_function_highlight   = 1
vim.g.cpp_attributes_highlight = 1
vim.g.cpp_member_highlight     = 1
vim.g.cpp_simple_highlight     = 1

-- Config NvimTree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.keymap.set('n', '<F1>', '<Cmd>NvimTreeToggle<CR>',      { silent = true })
vim.keymap.set('i', '<F1>', '<Esc><Cmd>NvimTreeToggle<CR>', { silent = true })

-- Config Indent highlight
local highlight = {
    'RainbowRed',
    'RainbowYellow',
    'RainbowBlue',
    'RainbowOrange',
    'RainbowGreen',
    'RainbowViolet',
    'RainbowCyan',
}

local hooks = require 'ibl.hooks'
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, 'RainbowRed',    { fg = '#E06C75' })
    vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
    vim.api.nvim_set_hl(0, 'RainbowBlue',   { fg = '#61AFEF' })
    vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
    vim.api.nvim_set_hl(0, 'RainbowGreen',  { fg = '#98C379' })
    vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
    vim.api.nvim_set_hl(0, 'RainbowCyan',   { fg = '#56B6C2' })
end)

require('ibl').setup {
  indent = {
    char = '┋', --'│',
    highlight = highlight
  },
  scope = {
    -- This is the horizontal bar
    enabled = false,
    show_start = false,
    show_end = false,
  },
}

-- Config BarBar
vim.keymap.set('n', '<A-z>',   '<Cmd>BufferPrevious<CR>',     { silent = true })
vim.keymap.set('n', '<A-x>',   '<Cmd>BufferNext<CR>',         { silent = true })
vim.keymap.set('n', '<A-s-z>', '<Cmd>BufferMovePrevious<CR>', { silent = true })
vim.keymap.set('n', '<A-s-x>', '<Cmd>BufferMoveNext<CR>',     { silent = true })
vim.keymap.set('n', '<A-c>',   '<Cmd>BufferClose<CR>',        { silent = true })
vim.keymap.set('n', '<A-s-c>', '<Cmd>BufferRestore<CR>',      { silent = true })
vim.keymap.set('n', '<A-t>',   '<Cmd>BufferPick<CR>',         { silent = true })

-- Config Zig 
vim.g.zig_fmt_autosave = 0

-- Config Telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', function() telescope.find_files() end)
vim.keymap.set('n', '<leader>fg', function() telescope.live_grep() end) -- NEEDS ripgred, install by mason
vim.keymap.set('n', '<leader>fb', function() telescope.buffers() end)
vim.keymap.set('n', '<leader>fh', function() telescope.help_tags() end)

-- Config vim-svelte
vim.g.vim_svelte_plugin_use_typescript = 1

-- COC --
--[[
vim.keymap.set('i', '<C-e>', 'coc#pum#visible() ? coc#pum#prev(1) : "\\<C-h>"',                                      { expr = true, silent = true })
vim.keymap.set('i', '<C-d>', 'coc#pum#visible() ? coc#pum#next(1) : coc#refresh()',                                  { expr = true, silent = true })
vim.keymap.set('i', '<C-f>', 'coc#pum#visible() ? coc#pum#confirm() : "\\<C-g>u\\<CR>\\<c-r>=coc#on_enter()\\<CR>"', { expr = true, silent = true })

vim.keymap.set('n', '<F2>',       '<Plug>(coc-rename)')
vim.keymap.set('n', '<leader>[',  '<Plug>(coc-diagnostic-prev)',   { silent = true })
vim.keymap.set('n', '<leader>]',  '<Plug>(coc-diagnostic-next)',   { silent = true })
vim.keymap.set('n', '<leader>\\', ':<C-u>CocList diagnostics<cr>', { silent = true })
vim.keymap.set('n', 'gd',         '<Plug>(coc-definition)',        { silent = true })
vim.keymap.set('n', 'gy',         '<Plug>(coc-type-definition)',   { silent = true })
vim.keymap.set('n', 'gi',         '<Plug>(coc-implementation)',    { silent = true })
vim.keymap.set('n', 'gr',         '<Plug>(coc-references)',        { silent = true })
]]--

-- [[ Treesitter ]]
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim' },
  auto_install = true,

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    -- move = {
    --   enable = true,
    --   set_jumps = true, -- whether to set jumps in the jumplist
    --   goto_next_start = {
    --     [']m'] = '@function.outer',
    --     [']]'] = '@class.outer',
    --   },
    --   goto_next_end = {
    --     [']M'] = '@function.outer',
    --     [']['] = '@class.outer',
    --   },
    --   goto_previous_start = {
    --     ['[m'] = '@function.outer',
    --     ['[['] = '@class.outer',
    --   },
    --   goto_previous_end = {
    --     ['[M'] = '@function.outer',
    --     ['[]'] = '@class.outer',
    --   },
    -- },
    -- swap = {
    --   enable = true,
    --   swap_next = {
    --     ['<leader>a'] = '@parameter.inner',
    --   },
    --   swap_previous = {
    --     ['<leader>A'] = '@parameter.inner',
    --   },
    -- },
  },
}

-- -- MASON + NVIM LSP --
require('mason').setup() 
require('mason-lspconfig').setup()

-- Set up nvim-cmp.
local cmp = require 'cmp'

cmp.setup({
  enabled = function()
    -- disable completion in comments
    local context = require 'cmp.config.context'
    -- keep command mode completion enabled when cursor is in a comment
    if vim.api.nvim_get_mode().mode == 'c' then
      return true
    else
      return not context.in_treesitter_capture('comment') 
        and not context.in_syntax_group('Comment')
    end
  end,
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-e>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.select_next_item(),
    ['<C-f>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
  {
    { name = 'buffer' },
  }),
  performance = {
    debounce = 250,
    max_view_entries = 10,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  }
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Set up lspconfig.
local nvim_cmp_lsp = require('cmp_nvim_lsp')
local capabilities = nvim_cmp_lsp.default_capabilities()
local lc = require('lspconfig')

require("clangd_extensions").setup({
  inlay_hints = {
    inline = vim.fn.has("nvim-0.10") == 1,
    only_current_line = false,
    only_current_line_autocmd = { "CursorHold" },
    show_parameter_hints = true,
    parameter_hints_prefix = "<- ",
    other_hints_prefix = "=> ",
    max_len_align = false,
    max_len_align_padding = 1,
    right_align = true,
    right_align_padding = 7,
    highlight = "Comment",
    priority = 100,
  },
  ast = {
    role_icons = {
      type = "🄣",
      declaration = "🄓",
      expression = "🄔",
      statement = ";",
      specifier = "🄢",
      ["template argument"] = "🆃",
    },
    kind_icons = {
      Compound = "🄲",
      Recovery = "🅁",
      TranslationUnit = "🅄",
      PackExpansion = "🄿",
      TemplateTypeParm = "🅃",
      TemplateTemplateParm = "🅃",
      TemplateParamObject = "🅃",
    },
    highlights = {
      detail = "Comment",
    },
  },
  memory_usage = {
    border = "none",
  },
  symbol_info = {
    border = "none",
  },
})

lc['clangd'].setup {
  capabilities = capabilities,
  settings = {
    clangd = {
      semanticHighlighting = true,
    },
  },
  on_attach = function(c)
    ceih = require("clangd_extensions.inlay_hints")
    ceih.setup_autocmd()
    ceih.set_inlay_hints()
  end,
}

lc['zls'].setup {
  capabilities = capabilities,
  settings = {
  },
  on_attach = function(c)
  end,
}

-- require('clangd_extensions').prepare({
-- })

lc['svelte'].setup {
  capabilities = capabilities,
  settings = {
    svelte = {
      plugin = {
        html = {
          completions = { enable = true }
        },
      },
      ['enable-ts-plugin'] = true,
    },
  },
  on_attach = function(client)
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = { '*.js', '*.ts' },
      callback = function(ctx)
        client.notify('$/onDidChangeTsOrJsFile', { uri = ctx.file })
      end,
    })
  end,
}

lc['ts_ls'].setup {
  capabilities = capabilities
}

lc['emmet_language_server'].setup {
  capabilities = capabilities,
  filetypes = { 'css', 'eruby', 'html', 'javascript', 'javascriptreact', 'less', 'sass', 'scss', 'pug', 'typescriptreact', 'vue' }, -- removed svelte since svelte has its own
}

-- More lspconfig setup

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    
    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>]', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<leader>[', vim.diagnostic.goto_prev)
    vim.keymap.set('n', '<leader>\\', function () vim.diagnostic.open_float(nil, {focus=false}) end)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
  end,
})

-- local updated_capabilities = vim.lsp.protocol.make_client_capabilities()
-- updated_capabilities.workspace.didChangeWatchedFiles = {
--   dynamicRegistration = true,
--   relativePatternSupport = true,
-- }

-- DAP --
local dap      = require('dap')
local dapui    = require('dapui')
local dapvtext = require('nvim-dap-virtual-text')

dapui.setup()
dapvtext.setup()

local dconf = {
  {
    name = 'Launch file',
    type = 'codelldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}
dap.adapters.codelldb = {
  type = 'server',
  host = '127.0.0.1',
  port = '13000',
  executable = {
    -- USE MASON
    command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
    args = {'--port', '13000'},
    -- On windows you may have to uncomment this:
    -- detached = false,
  }
}
dap.configurations.cpp = {
  {
    name = 'Launch file',
    type = 'codelldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    arg = function()
      return vim.fn.input('Arguments:')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}
dap.configurations.c = dap.configurations.cpp

vim.keymap.set('n', '<leader><F2>',  function() dap.toggle_breakpoint() end)
vim.keymap.set('n', '<leader><F6>',  function() dap.step_into() end)
vim.keymap.set('n', '<leader><F7>',  function() dap.step_over() end)
vim.keymap.set('n', '<leader><F8>',  function() dap.continue() end)
vim.keymap.set('n', '<leader><F9>', function() dap.repl.open() end)
vim.keymap.set('n', '<leader><F10>', function() dapui.toggle() end)

dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
dap.listeners.before.event_exited['dapui_config']     = function() dapui.close() end
