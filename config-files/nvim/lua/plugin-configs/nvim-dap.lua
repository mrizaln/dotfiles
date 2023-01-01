local keymap = vim.api.nvim_set_keymap

local opts = { noremap = true }

keymap('n', '<F5>',  ":lua require('dap').continue()<cr>", opts)
keymap('n', '<F10>', ":lua require('dap').step_over()<cr>", opts)
keymap('n', '<F11>', ":lua require('dap').step_into()<cr>", opts)
keymap('n', '<F12>', ":lua require('dap').step_out()<cr>", opts)
keymap('n', "<leader>b", ":lua require('dap').toggle_breakpoint()<cr>", opts)
keymap('n', "<leader>B", ":lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ))<cr>", opts)
keymap('n', "<leader>lp", ":lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Long point message'))<cr>", opts)
keymap('n', "<leader>dr", ":lua require('dap').repl.open()<cr>", opts)
keymap('n', "<leader>dl", ":lua require('dap').run_last()<cr>", opts)
