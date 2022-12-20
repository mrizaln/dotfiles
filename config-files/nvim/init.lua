--[[
    to run any vim command inside lua:
    vim.cmd [[<command> <args>]]
--]]

require('keybindings')
require('plugins')
require('global')
require('lsp_setup')

vim.cmd [[:COQnow -s]]

-- this is a cool function
local function blah()
    print "hello world\n"
end

-- determine host OS
if (vim.loop.os_uname().sysname ~= "Linux") then
    blah()
end
