local class = require('src.utils.middleclass')
require('src.utils.functions')
Parser = class('Parser')
-- Определение токенов по умолчанию
function Parser:initialize(config)
    self.al_sym = "[a-z]"
    self.stack_symbol = "[A-Y]"
    self.flag = "final"
    self.sep = ";"
    self.trans_sep = "->"
    self.empty = "ɛ"
    self.any = "*"
    self.bottom = "Z"
    self.prohibited = {"-", ","}
    self.prohibited['sep'] = self.sep
    self.prohibited['trans_sep'] = self.trans_sep
    self.prohibited['any'] = self.any
    self.prohibited['bottom'] = self.bottom
    self.prohibited['empty'] = self.empty
    self.prohibited['flag'] = self.flag
    self.states = {}

    local config_string = ""
    for line in io.lines(config) do
        config_string = config_string..line
    end
    config_string = delete_spaces(config_string)
    local lines = split(config_string, ',')
    for i = 1, #lines do
        local line = lines[i]
        if string.match(line, ']') == nil then
            print('Эта строка написана неверно:', line)
            goto continue
        end
        local sep = string.find(line, ']')
        local token = string.sub(line, 1, sep)
        local value = string.sub(line, sep + 1, #line + 1)
        if token == '[al-sym]' then
            self.al_sym = value
            for _,  elem in ipairs(self.prohibited) do
                if string.match(elem, value) then
                    error('Токен параметризирован не уникальным значением')
                end
            end
        elseif token == '[stack-symbol]' then
            self.stack_symbol = value
            for _,  elem in ipairs(self.prohibited) do
                if string.match(elem, value) then
                    error('Токен параметризирован не уникальным значением')
                end
            end
        elseif token == '[flag]' then
            self.flag = value
            table.remove(self.prohibited, 'flag')
            if has_value(self.prohibited, value) or string.match(value, self.al_sym) ~= nil or string.match(value, self.stack_symbol) ~= nil then
                error('Токен параметризирован не уникальным значением')
            end 
        elseif token == '[sep]' then
            self.sep = value
            table.remove(self.prohibited, 'sep')
            if has_value(self.prohibited, value) or string.match(value, self.al_sym) ~= nil or string.match(value, self.stack_symbol) ~= nil then
                error('Токен параметризирован не уникальным значением')
            end 
        elseif token == '[trans-sep]' then
            self.trans_sep = value
            table.remove(self.prohibited, 'trans_sep')
            if has_value(self.prohibited, value) or string.match(value, self.al_sym) ~= nil or string.match(value, self.stack_symbol) ~= nil then
                error('Токен параметризирован не уникальным значением')
            end 
        elseif token == '[empty]' then
            self.empty = value
            table.remove(self.prohibited, 'empty')
            if has_value(self.prohibited, value) or string.match(value, self.al_sym) ~= nil or string.match(value, self.stack_symbol) ~= nil then
                error('Токен параметризирован не уникthальным значением')
            end 
        elseif token == '[stack-any]' then
            self.any = value
            table.remove(self.prohibited, 'any')
            if has_value(self.prohibited, value) or string.match(value, self.al_sym) ~= nil or string.match(value, self.stack_symbol) ~= nil then
                error('Токен параметризирован не уникальным значением')
            end 
        elseif token == '[stack-bottom]' then
            self.bottom = value
            table.remove(self.prohibited, 'bottom')
            if has_value(self.prohibited, value) or string.match(value, self.al_sym) ~= nil or string.match(value, self.stack_symbol) ~= nil then
                error('Токен параметризирован не уникальным значением')
            end 
        else
            print('Эта строка написана неверно:', line)
            goto continue
        end
        ::continue::
    end
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
            error('В переходе появился символ, не принадлежащий входному алфавиту')
        end
        if string.match(before_separated[3], self.stack_symbol) == nil and before_separated[3] ~= self.bottom and before_separated[3] ~= self.any then
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
