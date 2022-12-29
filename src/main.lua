local Parser = require('src/parser/parser')
local parser = Parser:new('tests/test1/config.txt')
parser:parseAutomata('tests/test1/test1.txt')