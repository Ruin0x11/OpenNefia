local setmetatable = setmetatable
local pairs = pairs
local type = type
local function visit(node, graph, visited, ordered)
    if visited[node] == 0 then return 1 end
    if visited[node] == 1 then return end
    visited[node] = 0
    local deps = graph[node]
    for i=1, #deps do
        if visit(deps[i], graph, visited, ordered) then return 1 end
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
    for node in pairs(graph) do
        if visited[node] == nil then
            if visit(node, graph, visited, ordered) then
                return nil, "There is a circular dependency in the graph. It is not possible to derive a topological sort."
            end
        end
    end
    return ordered
end
return tsort
