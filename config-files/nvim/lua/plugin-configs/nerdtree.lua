local keymap = vim.api.nvim_set_keymap

local function nkeymap(key, map, opts)
    keymap('n', key, map, opts)
end

local opts = { noremap = true }
nkeymap('<c-t>', ':NERDTreeToggle<cr>', opts)

-- nnoremap <leader>n :NERDTreeFocus<CR>
-- nnoremap <C-n> :NERDTree<CR>
-- nnoremap <C-t> :NERDTreeToggle<CR>
-- nnoremap <C-f> :NERDTreeFind<CR>
