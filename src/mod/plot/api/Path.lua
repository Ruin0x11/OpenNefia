local Path = class.class("Path")

function Path:init(vertices, commands)
   vertices = vertices or {}
   commands = commands or {}
   assert(#vertices == #commands)
   self.vertices = vertices
   self.commands = commands
end

function Path.new_polygon(...)
   local vertices = {}
   for i = 1, select("#", ...), 2 do
      local x = select(i, ...)
      local y = select(i+1, ...)
      vertices[#vertices+1] = { x, y }
   end

   local commands = fun.duplicate("line_to"):take(#vertices):to_list()

   return Path:new(vertices, commands)
end

function Path:clear()
   self.vertices = {}
   self.commands = {}
end

function Path:move_to(x, y)
   table.insert(self.vertices, { x, y })
   table.insert(self.commands, "move_to")
end

function Path:line_to(x, y)
   table.insert(self.vertices, { x, y })
   table.insert(self.commands, "line_to")
end

function Path:iter()
   return fun.zip(self.vertices, self.commands)
end

return Path
