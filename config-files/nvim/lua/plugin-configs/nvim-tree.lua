require("nvim-tree").setup()

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true }

keymap('n', '<leader>t', ':NvimTreeToggle<cr>', opts)
keymap('n', '<leader>r', ':NvimTreeRefresh<cr>', opts)
keymap('n', '<leader>n', ':NvimTreeFindFile<cr>', opts)
