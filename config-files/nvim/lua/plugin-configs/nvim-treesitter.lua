-- treesitter
----------------
local configs = require'nvim-treesitter.configs'
configs.setup {
    ensure_installed = { 'bash', 'c', 'cmake', 'cpp', 'glsl', 'java', 'javascript', 'lua', 'python', 'typescript', 'vim' },
    highlight = {                           -- enable highlighting
        enable = true,
    },
    indent = {
        enable = true,                     -- default is disabled anyways
    }
}
----------------

