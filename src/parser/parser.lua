local class = require('src.utils.middleclass')
require('src.utils.functions')
Parser = class('Parser')
-- Определение токенов по умолчанию
function Parser:initialize()
    self.al_sym = "[0-1]"
    self.stack_symbol = "0"
    self.flag = "final"
    self.sep = ";"
    self.trans_sep = "->"
    self.empty = "ɛ"
    self.any = "*"
    self.bottom = "Z"
    self.prohibited = {"-", ",", self.trans_sep, self.any, self.bottom, self.empty, self.flag}
    self.states = {}
end


function Parser:parseAutomata(filename)
    local automata_string = ""
    for line in io.lines(filename) do
        automata_string = automata_string..line
    end
    -- Удаление пробельных символов
    automata_string = delete_spaces(automata_string)
    print(automata_string)
    local lines = split(automata_string, self.sep)
    -- Разбор состояний    
    local states_names = split(lines[1], ",")
    for i, name in ipairs(states_names) do
        local name_sep = split(name, "-")
        if #name_sep == 0 or #name_sep > 2 then
            error("Некорретная запись состояния")
        end
        if has_value(self.prohibited, name_sep[1]) then
            error("Запрещенное имя состояния")
        end
        for char in string.gmatch(name_sep[1], ".") do
            if has_value(self.prohibited, char) then
                error("Запрещенное имя состояния")
            end
        end
        table.insert(self.states, name_sep[1])
        if i == 1 then
            print('Это состояние стартовое', name_sep[1])
        end
        if #name_sep == 2 then
            if name_sep[2] ~= self.flag then
                error("Некорретный маркер завершающего состояния")
            end
            print('Это состояние завершающее', name_sep[1])
        end
    end
    -- Разбор переходов
    for i = 2, #lines do
        local transition = lines[i]
        local transition_separated = split(transition, self.trans_sep)
        if #transition_separated ~= 2 then
            error('Некорректная запись перехода')
        end
        local before = transition_separated[1]
        local after = transition_separated[2]
        local before_separated = split(before, ',')
        local after_separated = split(after, ',')
        if #before_separated ~= 3 or #after_separated ~= 2 then
            error('Некорректная запись перехода')
        end
        if #before_separated[1] == 0 or #before_separated[2] == 0 or #before_separated[3] == 0 or  #after_separated[1] == 0 or #after_separated[2] == 0 then
            error('Некорректная запись перехода')
        end
        if not has_value(self.states, before_separated[1]) or not has_value(self.states, after_separated[1]) then
            error('В переходе появилось необъявленное состояние')
        end
        if string.match(before_separated[2],self.al_sym) == nil and before_separated[2] ~= self.empty then
            print(before_separated[2])
            error('В переходе появился символ, не принадлежащий входному алфавиту')
        end
        if string.match(before_separated[3], self.stack_symbol) == nil and before_separated[3] ~= self.bottom and before_separated[3] ~= self.any then
            print(before_separated[3])
            error('В переходе появился символ, не принадлежащий стэковому алфавиту')
        end
        if #after_separated[2] == 1 then
            if after_separated[2] == self.any and before_separated[3] ~= self.any then
                error('Справа появился любой стэковый символ, а слева нет')
            end
            if after_separated[2] ~= self.bottom and before_separated[3] == self.bottom then
                error('Было считано дно стэка, но его не вернули')
            end
            if after_separated[2] == self.bottom and before_separated[3] ~= self.bottom then
                error('Дно стэка не было считано, но оно было снова записано')
            end
            if string.match(after_separated[2], self.stack_symbol) == nil and after_separated[2] ~= self.empty and after_separated[2] ~= self.bottom then
                print(after_separated[2])
                error('В переходе появился символ, не принадлежащий стэковому алфавиту')
            end
        else
            if after_separated[2] ~= self.empty then
                local before_last = string.sub(after_separated[2], 1, #after_separated[2] - 1)
                local last = string.sub(after_separated[2], -1)
                for char in string.gmatch(before_last, ".") do
                    if string.match(char, self.stack_symbol) == nil or char == self.bottom then
                        error('В переходе появился символ, не принадлежащий стэковому алфавиту')
                    end
                end
                if before_separated[3] == self.bottom and last ~= self.bottom then
                    error('Было считано дно стэка, но его не вернули')
                end
                if before_separated[3] ~= self.bottom then
                    if string.match(last, self.stack_symbol) == nil then
                        error('В переходе появился символ, не принадлежащий стэковому алфавиту')
                    end
                end
            else
                if before_separated[3] == self.bottom then
                    error('Было считано дно стэка, но его не вернули')
                end
            end
        end
        -- Тут нужно добавить переход в автомат
     end
end


return Parser
