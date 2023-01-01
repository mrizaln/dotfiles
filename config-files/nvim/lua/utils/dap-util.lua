----------------------[[ helper functions to load configuration ]]------------------------

local M = {}

-- to use general utils, make sure it is loaded first
--local general = _G.myUtils.general
local common = require('utils/general')

-- create new DAP configuration
local function createConfiguration(lang, opts)
    local dap = require('dap')
    dap.configurations[lang] = {
        opts
    }

    -- show program and args
    print("program: " .. opts.program)
    print("args: " .. common.arrayToStringSimple(opts.args, ", ", "[", "]"))
    -- print("$ <program> " .. general.arrayToStringSimple(args, " ", "", ""))
end

-- parse launch.json file
function M.loadLaunchJSON(workingPath)
    if workingPath == nil then
        workingPath = vim.fn.getcwd()
    end
    local file = workingPath .. "/launch.json"

    -- check file exist
    local file_handler = io.open(file, "r")
    if file_handler == nil then
        -- try open launch.json in .vscode if exist
        file = workingPath .. "/.vscode/launch.json"
        file_handler = io.open(file, "r")
        if file_handler == nil then
            print("File: '" .. file .. "' not exist")
            return
        end
    end
    print(file)

    -- read and parse json
    -- local text = file_handler:read("a")
    local text =  ""
    for line in file_handler:lines() do
        if string.match(line, ".*//.*") then
            -- print("comment: " .. line)
        else
            text = text .. line
        end
    end

    local json_tab = vim.fn.json_decode(text)
    io.close(file_handler)

    -- common.printTableRecurse("json_tab : ", json_tab)

    -- get configuration
    local cwd = json_tab.configurations[1].cwd
    local program = json_tab.configurations[1].program
    local args = json_tab.configurations[1].args

    local opts = {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = program,
        args = args,
        cwd = cwd,
        stopOnEntry = true,
    }
    -- local opts = json_tab.configurations[1]
    -- common.printTableRecurse("opts: ", opts)

    createConfiguration("cpp", opts)
end

return M
