-- Snippets are separated from the engine. Add this if you want them:
--Plugin 'honza/vim-snippets'

-- Trigger configuration. You need to change this to something other than <tab> if you use one of the following:
-- https://github.com/Valloric/YouCompleteMe
-- https://github.com/nvim-lua/completion-nvim

vim.cmd [[let g:UltiSnipsExpandTrigger="<tab>"]]
vim.cmd [[let g:UltiSnipsJumpForwardTrigger="<cr>"]]
vim.cmd [[let g:UltiSnipsJumpBackwardTrigger="<c-z>"]]

vim.cmd [[let g:UltiSnipsEditSplit="vertical"]]     --If you want :UltiSnipsEdit to split your window.

