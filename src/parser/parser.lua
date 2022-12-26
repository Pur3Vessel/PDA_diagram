local class = require('src.utils.middleclass')
require('src.utils.functions')
Parser = class('Parser')
-- Определение токенов по умолчанию
function Parser:initialize()
    self.al_sym = "[a-z]"
    self.stack_symbol = "[A-Y]"
    self.flag = "final"
    self.sep = ";"
    self.trans_sep = "->"
    self.empty = "ɛ"
    self.any = "*"
    self.bottom = "Z"
end


function Parser:parseAutomata(filename)
    local automata_string = ""
    for line in io.lines(filename) do
        automata_string = automata_string..line
    end
    -- Удаление пробельных символов
    automata_string = delete_spaces(automata_string)
    
end

return Parser
