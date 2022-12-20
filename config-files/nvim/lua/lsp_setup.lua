local function treesitter_setup()
    local configs = require'nvim-treesitter.configs'
    configs.setup {
        --[[ ensure_installed = "all", -- Only use parsers that are maintained --]]         -- makes my system hang :(
        ensure_installed = { 'bash', 'c', 'cmake', 'cpp', 'glsl', 'java', 'javascript', 'lua', 'python', 'typescript', 'vim' },
        ignore_install = { "phpdoc" }, -- https://github.com/claytonrcarter/tree-sitter-phpdoc/issues/15
        highlight = { -- enable highlighting
            enable = true,
        },
        indent = {
            enable = false,
        }
    }
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
end

local function lsp_setup()
    local lsp_installer = require("nvim-lsp-installer")
    local coq = require "coq"

    -- tell the server the capability of foldingRange
    -- nvim hasn't added foldingRange to default capabilities, users must add it manually
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
    }

    lsp_installer.on_server_ready(function(server)
        local opts = {
            capabilities = capabilities
        }

        if server.name == "sumneko_lua" then
            opts = {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { 'vim', 'use' }
                        },
                    --workspace = {
                        -- Make the server aware of Neovim runtime files
                    --library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true}
                --}
                    }
                }
            }
            server:setup(coq.lsp_ensure_capabilities(opts))
        else
            server:setup(coq.lsp_ensure_capabilities(opts))
        end
    end)

    -- c/cpp
    vim.cmd[[let g:cmake_link_compile_commands = 1]]
end

treesitter_setup()
lsp_setup()
