--[[
    to run any vim command inside lua:
    vim.cmd [[<command> <args>]]
--]]

require('keybindings')
require('plugins')
require('global')
require('lsp_setup')
require('dap_setup')
require('my_utils')

--vim.cmd [[:COQnow -s]]

-- this is a cool function
local function blah()
    print "It appears that you are not using Linux as your system\n"
end

-- determine host OS
if (vim.loop.os_uname().sysname ~= "Linux") then
    blah()
end
