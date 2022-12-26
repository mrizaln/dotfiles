-- codelldb uses TCP for the DAP communication
-- that requires using the server type for the adapter definition. See :help dap-adapter.


------------------------------[[ Adapter Definition ]]------------------------------------
local dap = require('dap')

-- you need to launch codellbd manually using this configuration below
--[[----------------------------------------------------------------------
dap.adapters.codelldb = {
  type = 'server',
  host = '127.0.0.1',
  port = 13000 -- Use the port printed out or specified with `--port`
}
------------------------------------------------------------------------]]

-- use this if you install codelldb using mason.nvim
local executable_path = os.getenv("HOME")..".local/share/nvim/mason/bin/codelldb"

-- launch automatically (codelldb >= v1.7.0)
dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    -- CHANGE THIS to your path!
    command = executable_path,
    args = {"--port", "${port}"},

    -- On windows you may have to uncomment this:
    -- detached = false,
  }
}
------------------------------------------------------------------------------------------
FILE_TO_DEBUG = [[/tmp/traffic/cmake_build_Debug/simulation]]
---------------------------------[[ Configuration ]]--------------------------------------
-- [  codelldb manual:  https://github.com/vadimcn/vscode-lldb/blob/master/MANUAL.md  ] --
-- cpp
dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function() return FILE_TO_DEBUG end,
    --program = function()
    --    local file_path = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    --    print(string.format([[%s]], file_path))
    --    return string.format([[%s]], file_path)
    --end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}

-- c
dap.configurations.c = dap.configurations.cpp;

-- rust
dap.configurations.rust = dap.configurations.cpp;
------------------------------------------------------------------------------------------
