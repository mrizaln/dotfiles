require'alpha'.setup(require'alpha.themes.startify'.config)

local startify = require('alpha.themes.startify')

startify.section.bottom_buttons.val = {
    startify.button('v', 'Neovim config', ':e ~/.config/nvim/init.lua<cr>'),
    startify.button('q', 'Quit nvim', ':qa<cr>'),
}

vim.api.nvim_set_keymap('n', '<c-n>', ':Alpha<cr>', { noremap = true })

