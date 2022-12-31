if #arg ~= 1 and #arg ~= 2 then
    error('Некорректный вызов программы')
end
local parser = nil
if #arg == 1 then
    local Parser = require('src/parser/parser')
    parser = Parser:new('')
else
    local Parser = require('src/parser/parser')
    parser = Parser:new(arg[2])
end
local pda = parser:parseAutomata(arg[1])
pda:to_graph()