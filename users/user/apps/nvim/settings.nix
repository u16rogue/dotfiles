{
    vim = {
        theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
        };
        options = {
            tabstop        = 4;
            softtabstop    = 4;
            shiftwidth     = 4;
            expandtab      = true;
            autoindent     = true;
            copyindent     = true;
            cmdheight      = 0;
            signcolumn     = "yes"; # space before line numbers
            showmatch      = true;
            termguicolors  = true;
            linebreak      = true;
            number         = true;
            relativenumber = true;
            ignorecase     = true;
            smartcase      = true;
            undofile       = true;
            wrap           = true;
            #listchars = {
            #    # space = "⋅";
            #    eol = "↴";
            #};
        };
        luaConfigRC.extra = /*lua*/ ''
            -- show cmd if recording macro
            vim.api.nvim_create_autocmd('RecordingEnter', { callback = function() vim.o.cmdheight = 1 end })
            vim.api.nvim_create_autocmd('RecordingLeave', { callback = function() vim.o.cmdheight = 0 end })
            -- auto create .nvimsession
            vim.api.nvim_create_autocmd("VimLeavePre", {
                callback = function()
                    local session_path = vim.fn.getcwd() .. "/.nvimsession"
                    if vim.fn.filereadable(session_path) == 1 then
                        vim.cmd("mksession! .nvimsession")
                    end
                end,
            })
            -- word wrap fix
            for _k, v in pairs({ 'j', 'k' }) do
                vim.keymap.set('n', v, 'v:count == 0 ? "g' .. v .. '" : "' .. v .. '"', { expr = true, silent = true })
            end
        '';
        clipboard = {
            enable = true;
            providers.wl-copy.enable = true;
        };
        statusline.lualine = {
            enable = true;
        };
        telescope = {
            enable = true;
            setupOpts.defaults.mappings.i = {
                "<C-d>" = "move_selection_next";
                "<C-e>" = "move_selection_previous";
                "<C-f>" = "select_default";
            };
            # mappings.lspDefinitions = "gd";
        };
        git.gitsigns = {
            enable = true;
            setupOpts.signs = {
                add.text = "+";
                change.text = "~";
                delete.text = "_";
                topdelete.text = "‾";
                changedelete.text = "~";
            };
        };
        autocomplete.nvim-cmp = {
            enable = true;
            mappings = {
                complete = null;
                confirm = "<C-f>";
                next = "<C-d>";
                previous = "<C-e>";
                close = null;
                scrollDocsUp = "<C-S-e>";
                scrollDocsDown = "<C-S-d>";
            };
        };
        visuals.indent-blankline = {
            enable = true;
            setupOpts = {
                indent.char = "┋"; # --'│';
                scope = {
                    # This is the horizontal bar
                    enabled = false;
                    show_start = false;
                    show_end = false;
                };
            };
        };
        visuals.nvim-web-devicons.enable = true;
        tabline.nvimBufferline = {
            enable = true;
            setupOpts = {
                options = {
                    show_buffer_icons = true;
                    show_buffer_close_icons = false;
                    show_close_icon = false;
                };
            };
            mappings = {
                closeCurrent = "<A-c>";
                cycleNext = "<A-x>";
                cyclePrevious = "<A-z>";
                moveNext = "<A-S-x>";
                movePrevious = "<A-S-z>";
            };
        };
        filetree.nvimTree = {
            enable = true;
            openOnSetup = false;
            setupOpts = {
                renderer = {
                    group_empty = true;
                    indent_width = 2;
                    indent_markers = { enable = true; inline_arrows = false; };
                };
                view = {
                    number = true;
                    float = {
                        enable = true;
                        open_win_config = { width = 80; height = 100; };
                    };
                };
                git.enable = true;
                modified.enable = true;
                filters.dotfiles = false;
            };
            mappings.toggle = "<F1>";
        };
        snippets.luasnip = {
            enable = true;
        };
        treesitter.context.enable = true;
        lsp = {
            enable = true;
            lspconfig.enable = true;
        };
        languages = {
            enableTreesitter = true;
            zig.enable = true;
            clang.enable = true;
            rust.enable = true;
            nix.enable = true;
            bash.enable = true;
            ts.enable = true;
            python.enable = true;
            lua.enable = true;
            svelte.enable = true;
            html.enable = true;
            css.enable = true;
        };
    };
}
