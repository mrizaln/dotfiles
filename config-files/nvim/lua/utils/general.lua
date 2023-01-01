local M = {}

-- check if a table is used as an array
function M.isArray(tab)
  return #tab > 0 and next(tab, #tab) == nil
end

-- print array recursively
function M.printArrayRecurse(prelude, arr, level)
    if level == nil then level = 0 end

    print(prelude .. "[")

    local indent = string.rep(" ", (level+1)*4)
    if arr ~= nil then
        for _, e in pairs(arr) do
            if type(e) == "table" then
                if M.isArray(e) then
                    M.printArrayRecurse(indent, e, level+1)
                else
                    M.printTableRecurse(indent, e, level+1)
                end
            else
                print(indent.." ("..type(e)..") "..tostring(e)..",")
            end
        end
    end

    local ending = string.rep(" ", (level)*4).."],"
    if level == 0 then ending = ending:sub(1, #ending-1) end
    print(ending)
end

-- return a string, every element will be converted using built-in tostring() function
function M.arrayToStringSimple(arr, sep, prelude, ending)
    local str = prelude
    for _,e in pairs(arr) do
        str = str .. tostring(e) .. sep
    end
    return string.sub(str, 0, string.len(str)-string.len(sep))..ending
end

-- print array, element by element (converted using built-in tostring() function)
function M.printArray(arr, sep, prelude, ending)
    print(M.arrayToStringSimple(arr, sep, prelude, ending))
end

-- print table recursively
function M.printTableRecurse(prelude, tab, level)
    if level == nil then level = 0 end

    print(prelude .. "{")

    local indent = string.rep(" ", (level+1)*4)
    if tab ~= nil then
        for k, e in pairs(tab) do
            if type(e) == "table" then
                if M.isArray(e) then
                    M.printArrayRecurse(indent..k.." : ", e, level+1)
                else
                    M.printTableRecurse(indent..k.." : ", e, level+1)
                end
            else
                print(indent..k.." : ("..type(e)..") "..tostring(e)..",")
            end
        end
    end

    local ending = string.rep(" ", (level)*4).."},"
    if level == 0 then ending = ending:sub(1, #ending-1) end
    print(ending)
end

-- if you don't know what kind of type you want to print, use this function
-- this function will print recursively if the type is a table
-- you should pass the argument as a new table
-- like this : printIDK({arg1, arg2}) or printIDK({name1=arg1, name2=arg2})
function M.printIDK(args)
    local level = 0
    local idk = args
    for name, tab in pairs(idk) do
        if type(tab) == "table" then
            if M.isArray(tab) then
                M.printArrayRecurse(name.." : ", tab, level)
            else
                M.printTableRecurse(name.." : ", tab, level)
            end
        else
            print(name.." : ("..type(tab)..") ", tab)
        end
    end
end

return M
