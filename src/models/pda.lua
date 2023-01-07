local class = require("src/utils/middleclass")
local Set = require("src/models/set")
local Transition = require("src/models/transition")
local Graphviz = require("src/lua-graphviz/graphviz")
require("src/utils/functions")

local PDA = class("PDA")

function PDA:initialize(states, start_state, final_states, alphabeth, stack_alphabeth, transitions, empty_symbol, any_symbol)
    self.states = states
    self.start_state = start_state
    self.final_states = final_states
    self.alphabeth = alphabeth
    self.stack_alphabeth = stack_alphabeth
    self.transitions = transitions

    self.empty_symbol = empty_symbol
    self.any_symbol = any_symbol

    self.traps = {}
    self:find_traps()

    self.deterministic_transitions = {}
    self:find_deterministic_transitions()

    self.stack_independent_transitions = {}
    self:find_stack_independent_transitions()
end

function PDA:find_traps()
    local not_traps = Set:new({})
    for _, v in pairs(self.final_states) do
        not_traps:add(v)
    end

    while true do
        local st_num = not_traps.size
        for _, tr in pairs(self.transitions) do
            if not_traps:has(tr.state_to) then
                not_traps:add(tr.state_from)
            end
        end
        local st_num_new = not_traps.size
        if st_num_new - st_num ~= 0 then
        else
            break
        end
    end

    for _, st in pairs(self.states) do
        if not not_traps:has(st) then
            table.insert(self.traps, st)
        end
    end
end

function PDA:find_deterministic_transitions()
    local det_tr = {}
    for ind, st in pairs(self.states) do
        -- находим все переходы из состояния
        local st_transits = {}
        for _, tr in pairs(self.transitions) do
            if tr.state_from == st then
                table.insert(st_transits, tr)
            end
        end

        for _, tr in pairs(st_transits) do
            local non_det = {}
            for _, v in pairs(st_transits) do
                -- print(tr.state_from, tr.state_to, v.state_from, v.state_to)
                if equal_tr(v, tr, self.empty_symbol, self.any_symbol) then
                    table.insert(non_det, v)
                end
            end
            -- print(tr.state_from, tr.state_to, tr.symbol, tr.stack_pop_symbol, table.length(non_det))
            print(tr:toString(), table.length(non_det))
            if table.length(non_det) == 1 then
                table.insert(det_tr, tr)
            end
        end
    end

    for k, v in pairs(det_tr) do
        v.is_det = true
        table.insert(self.deterministic_transitions, v)
    end
end

function PDA:find_stack_independent_transitions()
    for ind, tr in pairs(self.transitions) do
        if(tr.stack_pop_symbol == self.any_symbol and tr.stack_push_symbol == self.any_symbol) then
            table.insert(self.stack_independent_transitions, tr)
            tr.is_stack_ind = true
        end
    end
end

function PDA:to_graph()
    local graph = Graphviz()

    graph.nodes.style:update{
        fontname = "Inconsolata Regular"
    }
    local subgraphs_states = {}
    for k, v in pairs(self.states) do
        local sub = graph:subgraph(uuid_st())
        sub:node(v, v)
        sub.nodes.style:update{
            fontname = "Inconsolata Regular",
            shape = "oval"
        }
        if self.start_state == v then
            sub.nodes.style:update{
                fontname = "Inconsolata Regular",
                shape = "oval",
                color = "green"
            }
        end
        if has_value(self.final_states, v) then
            sub.nodes.style:update{
                fontname = "Inconsolata Regular",
                shape = "doublecircle"
            }
        elseif has_value(self.traps, v) then
            sub.nodes.style:update{
                fontname = "Inconsolata Regular",
                shape = "rectangle",
                color = "red"
            }
        end
        table.insert(subgraphs_states, sub)
    end

    for k, v in pairs(self.transitions) do
        local label = "label = " .. v:tr()
        if v.is_det then
            label  = label .. ", penwidth = 3"
        end
        if v.is_stack_ind then
            label = label .. ", color = \"green\""
        end
        graph:edge(v.state_from, v.state_to, label)
    end

    -- print(graph:source())

    graph:render("test")
end

function equal_tr(tr1, tr2, empty, any)
    return eq_sps(tr1.stack_pop_symbol, tr2.stack_pop_symbol, any) and eq_as(tr1.symbol, tr2.symbol, empty)
end

function eq_sps(s1, s2, any)
    return s1 == s2 or s1 == any or s2 == any
end

function eq_as(s1, s2, empty)
    return s1 == s2 or s1 == empty or s2 == empty
end

return PDA
-- q0, q1, q2, q3 - fin;
-- q0, 0, Z -> q1, 0Z;
-- q0, ɛ, Z -> q3, Z;
-- q1, 0, 0 -> q1, 00;
-- q1, 1, 0 -> q2, ɛ;
-- q2, 1, 0 -> q2, ɛ;
-- q2, ɛ, Z -> q3, Z

-- local tr = {Transition:new("q0", "q1", "0", "Z", "0Z"),
--             Transition:new("q0", "q3", "ɛ", "Z", "Z"),
--             Transition:new("q1", "q1", "0", "0", "00"),
--             Transition:new("q1", "q2", "1", "0", "ɛ"),
--             Transition:new("q2", "q2", "1", "0", "ɛ"),
--             Transition:new("q2", "q3", "ɛ", "Z", "Z")
--         }
-- local st = {"q0", "q1", "q2", "q3"}
-- local fin = {"q0", "q1", "q3"}
-- local p = PDA:new(st, "q0", fin, {"0", "1"}, {"0", "1"}, tr, empty, any)
-- print("===================")
-- for k, v in pairs(p.stack_independent_transitions) do 
--     print(v.state_from, v.state_to, v.symbol, v.stack_pop_symbol, v.stack_push_symbol)
-- end
-- for k, v in pairs(p) do
--     print(k, v)

-- end
-- for k, v in pairs(p.stack_independent_transitions) do
--     print(v:toString())
-- end

-- p:to_graph()
