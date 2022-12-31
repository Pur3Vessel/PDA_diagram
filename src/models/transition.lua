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

    self.is_det = false
    self.is_stack_ind = false
end

function Transition:equal(tr)
    if (self.symbol == empty) or (tr.symbol == empty) then
        return self.stack_pop_symbol ~= tr.stack_pop_symbol
    else
        return self.symbol == tr.symbol and self.stack_pop_symbol == tr.stack_pop_symbol
    end
end

function Transition:toString()
    return self.state_from .. " -> " .. self.symbol .. ", " .. self.stack_pop_symbol .. "/" .. self.stack_push_symbol .. " -> " .. self.state_to
end

function Transition:tr()
    return "\"" .. self.symbol .. ", " .. self.stack_pop_symbol .. "/" .. self.stack_push_symbol .. "\""
end

function Transition:tr1()
    return self.state_from .. self.symbol .. self.stack_pop_symbol .. self.stack_push_symbol .. self.state_to
end

return Transition
