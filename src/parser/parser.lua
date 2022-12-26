local class = require('src.utils.middleclass')

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
    print(self.sep)
    local automata_string = ""
    for line in io.lines(filename) do
        automata_string = automata_string..line
    end
    print(automata_string)
end
