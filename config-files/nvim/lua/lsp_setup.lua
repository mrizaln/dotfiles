-- setup treesitter

local nvim_lsp = require("lspconfig")

    -- tell the server the capability of foldingRange
    -- nvim hasn't added foldingRange to default capabilities, users must add it manually
--    local capabilities = vim.lsp.protocol.make_client_capabilities()
--    capabilities.textDocument.foldingRange = {
--        dynamicRegistration = false,
--        lineFoldingOnly = true
--    }

-- Set up lspconfig. (nvim-cmp)
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.

-- sumneko_lua
nvim_lsp['sumneko_lua'].setup {
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim', 'use', 'require' }
            },
        --workspace = {
            -- Make the server aware of Neovim runtime files
        --library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true}
    --}
        }
    }
}


-- ccls
-- nvim_lsp['ccls'].setup{
--     capabilities = capabilities,
--     -- root_dir = lsp.util.root_pattern('main.cpp', '.git'),
--     -- single_file_support = true
-- }
-- vim.cmd[[let g:cmake_link_compile_commands = 1]]

-- clangd
nvim_lsp['clangd'].setup{
    capabilities = capabilities,
    -- root_dir = lsp.util.root_pattern('main.cpp', '.git'),
    -- single_file_support = true
}
vim.cmd[[let g:cmake_link_compile_commands = 1]]

-- rust_analyzer
nvim_lsp['rust_analyzer'].setup({
    capabilities = capabilities,
    -- on_attach = function(client) require('completion').on_attach(client) end,
    settings = {
        ["rust-analyzer"] = {
            imports = {
                granularity = {
                    group = "module",
                },
                prefix = "self",
            },
            cargo = {
                buildScripts = {
                    enable = true,
                },
            },
            procMacro = {
                enable = true
            },
        }
    }
})
