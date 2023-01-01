require("cmake-tools").setup {
  cmake_command = "cmake",
  cmake_build_directory = "",
  cmake_build_directory_prefix = "cmake_build_", -- when cmake_build_directory is "", this option will be activated
  cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1" },
  cmake_build_options = {},
  cmake_console_size = 10, -- cmake output window height
  cmake_show_console = "always", -- "always", "only_on_error"
  cmake_dap_configuration = { name = "cpp", type = "codelldb", request = "launch" }, -- dap configuration, optional
  cmake_dap_open_command = require("dap").repl.open, -- optional
  cmake_variants_message = {
    short = { show = true },
    long = { show = false, max_length = 40 }
  }
}

local keymap = vim.api.nvim_set_keymap
keymap('', '<leader>cg', ':CMakeGenerate<cr>', {})
keymap('', '<leader>cb', ':CMakeBuild<cr>', {})
keymap('', '<leader>cq', ':CMakeClose<cr>', {})
keymap('', '<leader>cc', ':CMakeClean<cr>', {})

