--[[ three types of configuration options
--	global options (vim.o)			it seem vim.opt is recommended
--	local to window (vim.wo)
--	local to buffer (vim.bo)
--]]

vim.opt.expandtab = true            -- convert tab to spaces
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.clipboard = 'unnamedplus'   -- use system clipboard
vim.opt.cursorline = true           -- highlight current line
vim.opt.ttyfast = true              -- speed up scrolling
vim.cmd [[set cc=90]]             -- 90 column border

-- folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"


-- color scheme
-----------------
--vim.cmd [[colorscheme molokai]]
--vim.cmd [[let g:molokai_original = 1]]
--vim.cmd [[let g:rehash256 = 1]]

--vim.cmd [[colorscheme dracula]]

--vim.cmd [[colorscheme evening]]

--vim.cmd [[colorscheme nord]]

vim.cmd [[colorscheme sonokai]]
vim.cmd [[let g:sonokai_style = 'shusia' "atlantis/andromeda/shusia/maia]]
