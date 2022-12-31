-- Очень важно :)

function split(inputstr, sep)
    local t = {}
    for str in  string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function filter_string(str, predicate)
    local new_string = ""
    for char in string.gmatch(str, ".") do
        if predicate(char) then
            new_string = new_string..char
        end
    end
    return new_string
end

function delete_spaces(string)
    local predicate = function (s)
        return string.match(s, "%s") == nil
    end
    return filter_string(string, predicate)
end

function has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function table.length(arr)
    local size = 0
    for _ in pairs(arr) do
        size = size + 1
    end
    return size
end

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
 end
 