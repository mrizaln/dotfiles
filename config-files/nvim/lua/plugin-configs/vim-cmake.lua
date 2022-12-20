local keymap = vim.api.nvim_set_keymap

keymap('', '<leader>cg', ':CMakeGenerate<cr>', {})
keymap('', '<leader>cb', ':CMakeBuild<cr>', {})
keymap('', '<leader>cq', ':CMakeClose<cr>', {})
keymap('', '<leader>cc', ':CMakeClean<cr>', {})

vim.cmd [[let g:cmake_link_compile_commands = 1]]
-- vim.cmd [[let g:cmake_generate_options = ['-DCMAKE_EXPORT_COMPLILE_COMMANDS=ON']
