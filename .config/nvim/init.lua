-- Auto-install & setup lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath})
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

vim.opt.tabstop        = 4
vim.opt.softtabstop    = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true

vim.opt.autoindent     = true
vim.opt.copyindent     = true

vim.opt.cmdheight      = 0
vim.o.laststatus       = 3 -- keep status line at the bottom
vim.opt.showmode       = false
vim.opt.signcolumn     = 'yes'
vim.wo.wrap            = true
vim.opt.showcmd        = true
vim.opt.wildmenu       = true
vim.opt.showmatch      = true
vim.opt.termguicolors  = true
vim.opt.linebreak      = true
vim.opt.pumheight      = 10
vim.opt.number         = true -- show current linu number of cursor
vim.opt.relativenumber = true -- set line numbers relative to cursor

vim.opt.clipboard      = 'unnamedplus'

vim.opt.ignorecase     = true
vim.opt.smartcase      = true

-- file undo history
vim.opt.undofile       = true

-- whitespace visualization
vim.opt.list           = true
vim.opt.listchars:append 'space:⋅'
vim.opt.listchars:append 'eol:↴'
vim.o.pumblend = 0
vim.o.winblend = 0

vim.api.nvim_create_autocmd('RecordingEnter', { callback = function() vim.o.cmdheight = 1 end })
vim.api.nvim_create_autocmd('RecordingLeave', { callback = function() vim.o.cmdheight = 0 end })
vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        local session_path = vim.fn.getcwd() .. "/.nvimsession"
        if vim.fn.filereadable(session_path) == 1 then
            vim.cmd("mksession! .nvimsession")
        end
    end,
})

-- Config (n)Vim
vim.cmd [[highlight LineNr guifg=#fff]]

vim.diagnostic.config({
    virtual_text = true, -- show error message in-line of the error
    update_in_insert = false,
    severity_sort = true,
    checkCurrentLine = true,
    virtualTextCurrentLineOnly = true,
})

vim.o.updatetime = 250

require('lazy').setup({
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
    { 'romgrk/barbar.nvim',
        config = function ()
            -- Config BarBar
            vim.keymap.set('n', '<A-z>',   '<Cmd>BufferPrevious<CR>',     { silent = true })
            vim.keymap.set('n', '<A-x>',   '<Cmd>BufferNext<CR>',         { silent = true })
            vim.keymap.set('n', '<A-s-z>', '<Cmd>BufferMovePrevious<CR>', { silent = true })
            vim.keymap.set('n', '<A-s-x>', '<Cmd>BufferMoveNext<CR>',     { silent = true })
            vim.keymap.set('n', '<A-c>',   '<Cmd>BufferClose<CR>',        { silent = true })
            vim.keymap.set('n', '<A-s-c>', '<Cmd>BufferRestore<CR>',      { silent = true })
            vim.keymap.set('n', '<A-t>',   '<Cmd>BufferPick<CR>',         { silent = true })
        end,
    },

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
        config = function ()
            -- Config NvimTree
            require('nvim-tree').setup({
                renderer = { group_empty = true, indent_width = 2, indent_markers = { enable = true, inline_arrows = false } },
                git = { ignore = false },
                view = { number = true, float = { enable = true, open_win_config = { width = 80, height = 100 } } },
                filters = { dotfiles = false },
            })
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
            vim.keymap.set('n', '<F1>', '<Cmd>NvimTreeToggle<CR>',      { silent = true })
            vim.keymap.set('i', '<F1>', '<Esc><Cmd>NvimTreeToggle<CR>', { silent = true })
        end
    },

    -- Tree-sitter
    { 'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function ()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { 'c', 'cpp', 'zig', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim' },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = 'gn',
                        node_incremental = 'gn',
                        scope_incremental = 'gr',
                        -- node_decremental = '<M-space>',
                    },
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                        keymaps = {
                            -- UNUSED --
                             -- ['aa'] = '@parameter.outer',
                             -- ['ia'] = '@parameter.inner',
                             -- ['af'] = '@function.outer',
                             -- ['if'] = '@function.inner',
                             -- ['ac'] = '@class.outer',
                             -- ['ic'] = '@class.inner',
                        },
                    },
                    -- UNUSED --
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
        end,
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
        config = function ()
            -- Config Telescope
            local telescope = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', telescope.find_files)
            vim.keymap.set('n', '<leader>fg', telescope.live_grep) -- NEEDS ripgrep
            vim.keymap.set('n', '<leader>fb', telescope.buffers)
            vim.keymap.set('n', 'gd', telescope.lsp_definitions)
            -- UNUSED --
            -- vim.keymap.set('n', '<leader>fh', telescope.help_tags)
        end,
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
            -- UNUSED --
            -- on_attach = function(bufnr)
            --     local gs = require('gitsigns')
            --     vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

            --     -- don't override the built-in and vim-fugitive keymaps
            --     vim.keymap.set({'n', 'v'}, ']c', function()
            --         if vim.wo.diff then return ']c' end
            --         vim.schedule(function() gs.next_hunk() end)
            --         return '<Ignore>'
            --     end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
            --     vim.keymap.set({'n', 'v'}, '[c', function()
            --         if vim.wo.diff then return '[c' end
            --         vim.schedule(function() gs.prev_hunk() end)
            --         return '<Ignore>'
            --     end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
            -- end,
        },
    },

    -- Indentation visuals
    { 'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        config = function ()
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
        end,
    },

    -- [[ MASON + NVIM-LSP ]] --
    { 'williamboman/mason.nvim',
        build = ':MasonUpdate',
        config = function ()
            require('mason').setup()
        end,
    },

    { 'williamboman/mason-lspconfig.nvim',
        config = function () require('mason-lspconfig').setup {} end,
    },

    { 'neovim/nvim-lspconfig',
        config = function ()
            local nvim_cmp_lsp = require('cmp_nvim_lsp')
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                callback = function(ev)
                    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
                    local opts = { buffer = ev.buf }
                    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
                    vim.keymap.set('n', '<leader>]', vim.diagnostic.goto_next)
                    vim.keymap.set('n', '<leader>[', vim.diagnostic.goto_prev)
                    vim.keymap.set('n', '<leader>\\', function () vim.diagnostic.open_float(nil, {focus=false}) end)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    -- UNUSED --
                    --vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                    --vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
                    --vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
                    --vim.keymap.set('n', '<space>wl', function()
                    --    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    --end, opts)
                    -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
                    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts) -- use telescope's
                    --vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    --vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                end,
            })
        end,
    },

    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',

    {'hrsh7th/nvim-cmp',
        config = function ()
            local cmp = require 'cmp'
            cmp.setup({
                enabled = function()
                    -- disable completion in comments
                    local context = require 'cmp.config.context'
                    -- disable completion on comments when in insert mode
                    if vim.api.nvim_get_mode().mode ~= 'i' then
                      return true
                    else
                      return not context.in_treesitter_capture('comment')
                        and not context.in_syntax_group('Comment')
                    end
                end,
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-e>'] = cmp.mapping.select_prev_item(),
                    ['<C-d>'] = cmp.mapping.select_next_item(),
                    ['<C-f>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = 'luasnip' },
                    { name = 'nvim_lsp' },
                },
                {
                    { name = 'buffer' },
                }),
                performance = {
                    debounce = 250,
                    -- max_view_entries = 10,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                }
            })

            -- Set configuration for specific filetype.
            cmp.setup.filetype('gitcommit', {
                sources = cmp.config.sources({
                    { name = 'git' },
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
        end,
    },

    { 'L3MON4D3/LuaSnip',
        config = function ()
            local ls = require("luasnip")
            local s = ls.snippet
            local t = ls.text_node
            local i = ls.insert_node

            ls.add_snippets("typescript", {
                s("try", {
                    t({ 'try {', '' }),
                    t({ '    ' }), i(1), t({'',''}),
                    t({ '} catch (ex) {', '' }),
                    t({ '    console.error(ex);', '' }),
                    t({ '}' }),
                }),
            })

            ls.add_snippets("svelte", {
                s('app-path', { t({ 'import * as app_paths from "$app/paths";' }) }),
            })

            ls.add_snippets("zig", {
                s("import-std", {
                    t({ 'const std = @import("std");' }),
                }),
                s("Allocator", {
                    t({ 'std.mem.Allocator' }),
                }),
                s("assert", {
                    t({ 'std.debug.assert(' }), i(1), t({ ');' }),
                }),
            })

            ls.add_snippets("cpp", {
                s("try", {
                    t({ 'try {', '' }),
                    t({ '    ' }), i(1), t({'',''}),
                    t({ '} catch (const std::exception & ex) {', '' }),
                    t({ '}' }),
                }),
            })
        end,
    },

    { 'saadparwaiz1/cmp_luasnip',
        dependencies = {
            { 'L3MON4D3/LuaSnip' },
        },
    },

    { 'p00f/clangd_extensions.nvim',
        config = function ()
            require("clangd_extensions").setup({
                --[[
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
                ]]--
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
        end
    },

    -- Integration Development
    'skywind3000/asyncrun.vim',

    -- Debugging
    { 'mfussenegger/nvim-dap',
        config = function ()
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
        end,
    },

    'nvim-neotest/nvim-nio',

    { "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
    },

    'theHamsta/nvim-dap-virtual-text',

    'tpope/vim-ragtag',

    -- Language
    'sheerun/vim-polyglot',
    { 'leafOfTree/vim-svelte-plugin',
        config = function()
            -- Config vim-svelte
            vim.g.vim_svelte_plugin_use_typescript = 1
            vim.g.vim_svelte_plugin_open_devdocs = 0
        end,
    },

    { 'ziglang/zig.vim',
        config = function ()
            -- Config Zig
            vim.g.zig_fmt_autosave = 0
        end,
    },

    { 'bfrg/vim-cpp-modern',
        config = function ()
            -- Config vim-cpp-modern
            vim.g.cpp_function_highlight   = 1
            vim.g.cpp_attributes_highlight = 1
            vim.g.cpp_member_highlight     = 1
            vim.g.cpp_simple_highlight     = 1
        end,
    },

    -- Multi-case, regex replace
    'tpope/vim-abolish',

    -- Align plugin
    { 'junegunn/vim-easy-align',
        config = function ()
            -- Easy align
            vim.keymap.set('x', '<leader>aa', '<plug>(EasyAlign)', { silent = true }) -- align align
        end,
    },

    -- Scope splitter / joiner
    { 'Wansmer/treesj',
        -- keys = { '<space>m', '<space>j', '<space>s' },
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        config = function()
            require('treesj').setup({ use_default_keymaps = false })
            -- Scope split
            vim.keymap.set('n', '<leader>as', '<Cmd>TSJToggle<CR>', { silent = true }) -- align scope
        end,
    },
})
