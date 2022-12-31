local class = require("src/utils/middleclass")
require("src/utils/functions")

local Transition = class("Transition")

local empty = "ɛ"
local any = "*"

function Transition:initialize(state_from, state_to, symbol, stack_pop_symbol, stack_push_symbol)
    self.state_from = state_from
    self.state_to = state_to
    self.symbol = symbol
    self.stack_pop_symbol = stack_pop_symbol
    self.stack_push_symbol = stack_push_symbol
end

function Transition:equal(tr)
    if (self.symbol == empty) or (tr.symbol == empty) then
        return self.stack_pop_symbol ~= tr.stack_pop_symbol
    else
        return self.symbol == tr.symbol and self.stack_pop_symbol == tr.stack_pop_symbol
    end
end

return Transition
