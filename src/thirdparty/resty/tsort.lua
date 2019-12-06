local setmetatable = setmetatable
local pairs = pairs
local type = type
local function visit(node, graph, visited, ordered, cycle)
    if visited[node] == 0 then
       cycle[#cycle+1] = node
       return 1
    end
    if visited[node] == 1 then return end
    visited[node] = 0
    cycle[#cycle+1] = node
    local deps = graph[node]
    _ppr(node, deps)
    for i=1, #deps do
        if visit(deps[i], graph, visited, ordered, cycle) then return 1 end
    end
    visited[node] = 1
    ordered[#ordered+1] = node
end
local tsort = {}
tsort.__index = tsort
function tsort.new()
    return setmetatable({ graph = {} }, tsort)
end
function tsort:add(...)
    local p = { ... }
    local c = #p
    if c == 0 then return self end
    if c == 1 then
        p = p[1]
        if type(p) == "table" then
            c = #p
        else
            p = { p }
        end
    end
    local graph = self.graph
    for i=1, c do
        local f = p[i]
        if graph[f] == nil then graph[f] = {} end
    end
    for i=2, c, 1 do
        local f = p[i]
        local t = p[i-1]
        local o = graph[f]
        o[#o+1] = t
    end
    return self
end
function tsort:sort()
    local graph = self.graph
    local ordered = {}
    local visited = {}
    local cycle = {}
    for node in pairs(graph) do
        if visited[node] == nil then
            if visit(node, graph, visited, ordered, cycle) then
                return nil, cycle
            end
        end
    end
    return ordered
end
return tsort
