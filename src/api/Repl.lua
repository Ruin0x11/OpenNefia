local field = require("game.field")

local Repl = {}

function Repl.send(code)
   field.repl:execute(code)
end

function Repl.query()
   return field:query_repl()
end

function Repl.get()
   return field.repl
end

function Repl.clear()
   return Repl.get():clear()
end

function Repl.copy_last_input()
   return Repl.get():copy_last_input()
end

return Repl
