-- aliases
-- vim.api.nvim_set_keymap({mode{, {keymap}, {mapped to}, {options})
local keymap = vim.api.nvim_set_keymap
local function nkeymap(key, map, opts)
    if opts == nil then opts = {} end
    keymap('n', key, map, opts)
end

-- save on ctrl+s
keymap('n', '<c-s>', ':w<CR>', {})
keymap('i', '<c-s>', '<Esc>:w<CR>a', {})

-- move between pane
local opts = { noremap = true }
nkeymap('<c-j>', '<c-w>j', opts)
nkeymap('<c-h>', '<c-w>h', opts)
nkeymap('<c-k>', '<c-w>k', opts)
nkeymap('<c-l>', '<c-w>l', opts)

-- move split panes
nkeymap('<A-h>', '<c-w>H', opts)
nkeymap('<A-j>', '<c-w>J', opts)
nkeymap('<A-k>', '<c-w>K', opts)
nkeymap('<A-l>', '<c-w>L', opts)

-- lsp
nkeymap('gd', ':lua vim.lsp.buf.definition()<cr>', opts)
nkeymap('gD', ':lua vim.lsp.buf.declaration()<cr>', opts)
nkeymap('gi', ':lua vim.lsp.buf.implementation()<cr>', opts)
nkeymap('gw', ':lua vim.lsp.buf.document_symbol()<cr>', opts)
nkeymap('gw', ':lua vim.lsp.buf.workspace_symbol()<cr>', opts)
nkeymap('gr', ':lua vim.lsp.buf.references()<cr>', opts)
nkeymap('gt', ':lua vim.lsp.buf.type_definition()<cr>', opts)
nkeymap('K', ':lua vim.lsp.buf.hover()<cr>', opts)
nkeymap('<c-k>', ':lua vim.lsp.buf.signature_help()<cr>', opts)
nkeymap('<leader>af', ':lua vim.lsp.buf.code_action()<cr>', opts)
nkeymap('<leader>rn', ':lua vim.lsp.buf.rename()<cr>', opts)

opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
