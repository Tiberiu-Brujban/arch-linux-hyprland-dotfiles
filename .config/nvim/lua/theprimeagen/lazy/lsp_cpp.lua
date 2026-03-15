return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lsp',
        'saadparwaiz1/cmp_luasnip',
        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets',
    },

    config = function()
        -- Mason setup
        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = { 'clangd', 'basedpyright' },
        })

        -- LSP keymaps
        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(event)
                local opts = { buffer = event.buf }
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
                vim.keymap.set({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end, opts)
                vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
            end,
        })

        -- Diagnostic visuals
        vim.diagnostic.config({
            virtual_text = true,
            severity_sort = true,
            float = { border = 'rounded', source = 'always' },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '✘',
                    [vim.diagnostic.severity.WARN]  = '▲',
                    [vim.diagnostic.severity.HINT]  = '⚑',
                    [vim.diagnostic.severity.INFO]  = '»',
                },
            },
        })

        -- Capabilities for completion
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- clangd (C/C++)
        vim.lsp.config['clangd'] = {
            cmd = { 'clangd', '--background-index', '--clang-tidy', '--header-insertion=never', '--cross-file-rename' },
            capabilities = capabilities,
        }
        vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'c', 'cpp', 'h', 'hpp' },
            callback = function(args)
                vim.lsp.start(vim.lsp.config['clangd'], { bufnr = args.buf })
            end,
        })

        -- basedpyright (Python)
        vim.lsp.config['basedpyright'] = {
            capabilities = capabilities,
            settings = {
                basedpyright = {
                    analysis = { typeCheckingMode = "basic" },
                },
            },
        }
        vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'python' },
            callback = function(args)
                vim.lsp.start(vim.lsp.config['basedpyright'], { bufnr = args.buf })
            end,
        })

        -- OmniSharp (C# / .NET)
        local omnisharp_path = "/home/tiberiu/omnisharp/OmniSharp" -- înlocuiește cu calea ta
        vim.lsp.config['omnisharp'] = {
            cmd = { omnisharp_path, "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
            capabilities = capabilities,
            enable_roslyn_analyzers = true,
            organize_imports_on_format = true,
            use_mono = false,
        }
        vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'cs' },
            callback = function(args)
                vim.lsp.start(vim.lsp.config['omnisharp'], { bufnr = args.buf })
            end,
        })

        -- nvim-cmp setup
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        require('luasnip.loaders.from_vscode').lazy_load()
        vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

        cmp.setup({
            snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<Tab>'] = cmp.mapping.select_next_item({ behavior = 'select' }),
                ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
            }),
            sources = { { name = 'nvim_lsp' }, { name = 'buffer' }, { name = 'path' }, { name = 'luasnip' } },
            window = { documentation = cmp.config.window.bordered() },
        })
    end,
}

