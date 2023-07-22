set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set copyindent
set cmdheight=0
set noshowmode
set signcolumn=yes
set number
set showcmd
set wildmenu
set showmatch
set termguicolors
set linebreak
set pumheight=10
lua vim.cmd [[ autocmd RecordingEnter * set cmdheight=1 ]]
\   vim.cmd [[ autocmd RecordingLeave * set cmdheight=0 ]]

call plug#begin('~/.local/share/nvim/site/plugged')

" Icons
Plug 'nvim-tree/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'

" Themes
Plug 'catppuccin/nvim', {'as': 'catppuccin'}

" Interface
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-lualine/lualine.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.x' }
" ! Install ripgrep

" Language
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'sheerun/vim-polyglot'
Plug 'leafOfTree/vim-svelte-plugin'
Plug 'tpope/vim-ragtag'
Plug 'ziglang/zig.vim'
Plug 'bfrg/vim-cpp-modern'
"Plug 'p00f/clangd_extensions.nvim'

"" -- [[ MASON + NVIM-LSP ]] --
"Plug 'williamboman/mason.nvim', { 'do': ':MasonUpdate' }
"Plug 'williamboman/mason-lspconfig.nvim'
"Plug 'neovim/nvim-lspconfig'
"Plug 'hrsh7th/cmp-nvim-lsp'
"Plug 'hrsh7th/cmp-buffer'
"Plug 'hrsh7th/cmp-path'
"Plug 'hrsh7th/cmp-cmdline'
"Plug 'hrsh7th/nvim-cmp'
"Plug 'L3MON4D3/LuaSnip'
"Plug 'saadparwaiz1/cmp_luasnip'

"" -- [[ COC ]] --
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Integration Development
Plug 'skywind3000/asyncrun.vim'

call plug#end()

" -- Config (n)Vim
colorscheme catppuccin-mocha
highlight LineNr guifg=#fff
lua <<EOF
  vim.diagnostic.config({
    -- virtual_text = false,
    update_in_insert = false,
    severity_sort = true,
    checkCurrentLine = true,
    virtualTextCurrentLineOnly = true,
  })
  vim.o.updatetime = 250
  -- vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
EOF

"" -- Config vim-cpp-modern
let g:cpp_function_highlight = 1
let g:cpp_attributes_highlight = 1
let g:cpp_member_highlight = 1
let g:cpp_simple_highlight = 1

"" -- Config lualine
lua require('lualine').setup {
\  options = {
\    icons_enabled = true,
\    theme = 'auto',
\    component_separators = { left = '', right = ''},
\    section_separators = { left = '', right = ''},
\    always_divide_middle = true,
\    globalstatus = false,
\    refresh = {
\      statusline = 1000,
\      tabline = 1000,
\      winbar = 1000,
\    }
\  },
\  sections = {
\    lualine_a = {'mode'},
\    lualine_b = {'branch', 'diff', 'diagnostics'},
\    lualine_c = {{
\      'filename',
\      path = 3,
\    }},
\    lualine_x = {'encoding', 'fileformat', 'filetype'},
\    lualine_y = {'progress'},
\    lualine_z = {'location'}
\  },
\  inactive_sections = {
\    lualine_c = {'filename'},
\    lualine_x = {'location'},
\  },
\}

"" -- Config nvim-tree
lua vim.g.loaded_netrw = 1
lua vim.g.loaded_netrwPlugin = 1
lua require('nvim-tree').setup({
\     renderer = {
\           group_empty = true,
\           indent_width = 2,
\           indent_markers = {
\                 enable = true,
\                 inline_arrows = false,
\           },
\     }, 
\     git = {
\           ignore = false, 
\     },
\     view = {
\           number = true,
\           float = {
\                 enable = true,
\                 open_win_config = {
\                       width = 80,
\                       height = 100,
\                 },
\           },
\     },
\})
nnoremap <silent> <F1> <Cmd>NvimTreeToggle<CR>
inoremap <silent> <F1> <Esc><Cmd>NvimTreeToggle<CR>

"" -- Config Indent highlight
lua vim.opt.termguicolors = true
\   vim.cmd [[highlight IndentBlanklineIndent1 guifg=#E06C75 gui=nocombine]]
\   vim.cmd [[highlight IndentBlanklineIndent2 guifg=#E5C07B gui=nocombine]]
\   vim.cmd [[highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine]]
\   vim.cmd [[highlight IndentBlanklineIndent4 guifg=#56B6C2 gui=nocombine]]
\   vim.cmd [[highlight IndentBlanklineIndent5 guifg=#61AFEF gui=nocombine]]
\   vim.cmd [[highlight IndentBlanklineIndent6 guifg=#C678DD gui=nocombine]]
\   vim.opt.list = true
\   vim.opt.listchars:append "space:⋅"
\   vim.opt.listchars:append "eol:↴"
\ require("indent_blankline").setup {
\  char = '│',
\  space_char_blankline = ' ',
\  char_highlight_list = {
\    'IndentBlanklineIndent1','IndentBlanklineIndent2','IndentBlanklineIndent3','IndentBlanklineIndent4','IndentBlanklineIndent5','IndentBlanklineIndent6',
\  },
\}

"" -- Config BarBar
nnoremap <silent> <A-z>   <Cmd>BufferPrevious<CR>
nnoremap <silent> <A-x>   <Cmd>BufferNext<CR>
nnoremap <silent> <A-s-z> <Cmd>BufferMovePrevious<CR>
nnoremap <silent> <A-s-x> <Cmd>BufferMoveNext<CR>
nnoremap <silent> <A-c>   <Cmd>BufferClose<CR>
nnoremap <silent> <A-s-c> <Cmd>BufferRestore<CR>
nnoremap <silent> <A-t>   <Cmd>BufferPick<CR>

"" -- Config Zig 
let g:zig_fmt_autosave = 0
 
"" -- Config Telescope
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

"" -- Config vim svelte
let g:vim_svelte_plugin_use_typescript = 1

"" -- [[ COC ]] --
inoremap <silent><expr> <C-d>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ coc#refresh()
inoremap <silent><expr> <C-e> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <C-f> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <F2> <Plug>(coc-rename)
nmap <silent> <leader>[ <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>] <Plug>(coc-diagnostic-next)
nmap <silent> <leader>\ :<C-u>CocList diagnostics<cr>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

"" -- [[ MASON + NVIM LSP ]] --
"lua <<EOF
"  require("mason").setup()
"  require("mason-lspconfig").setup()
"
"  -- Set up nvim-cmp.
"  local cmp = require'cmp'
"
"  cmp.setup({
"    enabled = function()
"      -- disable completion in comments
"      local context = require 'cmp.config.context'
"      -- keep command mode completion enabled when cursor is in a comment
"      if vim.api.nvim_get_mode().mode == 'c' then
"        return true
"      else
"        return not context.in_treesitter_capture("comment") 
"          and not context.in_syntax_group("Comment")
"      end
"    end,
"    snippet = {
"      expand = function(args)
"        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
"      end,
"    },
"    mapping = cmp.mapping.preset.insert({
"      ['<C-e>'] = cmp.mapping.select_prev_item(),
"      ['<C-d>'] = cmp.mapping.select_next_item(),
"      ['<C-f>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
"    }),
"    sources = cmp.config.sources({
"      { name = 'nvim_lsp' },
"      { name = 'luasnip' },
"    },
"    {
"      { name = 'buffer' },
"    }),
"    performance = {
"      debounce = 250,
"      max_view_entries = 10,
"    },
"  })
"
"  -- Set configuration for specific filetype.
"  cmp.setup.filetype('gitcommit', {
"    sources = cmp.config.sources({
"      { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
"    }, {
"      { name = 'buffer' },
"    })
"  })
"
"  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
"  cmp.setup.cmdline({ '/', '?' }, {
"    mapping = cmp.mapping.preset.cmdline(),
"    sources = {
"      { name = 'buffer' }
"    }
"  })
"
"  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
"  cmp.setup.cmdline(':', {
"    mapping = cmp.mapping.preset.cmdline(),
"    sources = cmp.config.sources({
"      { name = 'path' }
"    }, {
"      { name = 'cmdline' }
"    })
"  })
"
"  -- Set up lspconfig.
"  local nvim_cmp_lsp = require('cmp_nvim_lsp')
"  local capabilities = nvim_cmp_lsp.default_capabilities()
"  local lc = require('lspconfig')
"
"  lc['clangd'].setup {
"    capabilities = capabilities,
"    settings = {
"      clangd = {
"        semanticHighlighting = true,
"      },
"    },
"  }
"
"  -- require('clangd_extensions').prepare({
"  -- })
"
"  lc['svelte'].setup {
"    capabilities = capabilities,
"    settings = {
"      svelte = {
"        plugin = {
"          html = {
"            completions = { enable = true }
"          },
"        },
"        ['enable-ts-plugin'] = true,
"      },
"    },
"    on_attach = function(client)
"      vim.api.nvim_create_autocmd("BufWritePost", {
"        pattern = { "*.js", "*.ts" },
"        callback = function(ctx)
"          client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
"        end,
"      })
"    end,
"  }
"
"  lc['tsserver'].setup {
"    capabilities = capabilities
"  }
"
"  lc['emmet_language_server'].setup {
"    capabilities = capabilities,
"    filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "pug", "typescriptreact", "vue" }, -- removed svelte since svelte has its own
"  }
"
"  -- More lspconfig setup
"
"  vim.api.nvim_create_autocmd('LspAttach', {
"    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
"    callback = function(ev)
"      -- Enable completion triggered by <c-x><c-o>
"      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
"
"      -- Buffer local mappings.
"      -- See `:help vim.lsp.*` for documentation on any of the below functions
"      local opts = { buffer = ev.buf }
"      
"      vim.keymap.set('n', '<leader>\\', function () vim.diagnostic.open_float(nil, {focus=false}) end)
"      vim.keymap.set('n', '<leader>]', vim.diagnostic.goto_next)
"      vim.keymap.set('n', '<leader>[', vim.diagnostic.goto_prev)
"      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
"      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
"      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
"      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
"      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
"      vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
"      vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
"      vim.keymap.set('n', '<space>wl', function()
"        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
"      end, opts)
"      vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
"      vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
"    end,
"  })
"
"  -- local updated_capabilities = vim.lsp.protocol.make_client_capabilities()
"  -- updated_capabilities.workspace.didChangeWatchedFiles = {
"  --   dynamicRegistration = true,
"  --   relativePatternSupport = true,
"  -- }
"EOF
