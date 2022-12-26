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

