local Codegen = require("api.Codegen")
local Env = require("api.Env")
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
   local line = Repl.get():last_input()
   Env.set_clipboard_text(line)
   return line
end

function Repl.copy_last_output()
   local line = Repl.get():last_output()
   Env.set_clipboard_text(line)
   return line
end

function Repl.wrap_last_input_as_function()
   local line = Repl.get():last_input()
   if not line then return end

   line = "return " .. line

   -- HACK instead save mod sandbox somewhere
   local env = Repl.get().env
   local f, err = Codegen.loadstring(line)
   if f then
      setfenv(f, env)
   end
   return f, err
end

function Repl.wrap_last_input_as_iterator()
   local f, err = Repl.wrap_last_input_as_function()
   if not f then
      return f, err
   end

   return fun.tabulate(f)
end

--- Queues a code block that runs the next time execution enters the
--- player's control. If the code returns a turn result, it is used as
--- the player's turn.
function Repl.defer_execute(code)
   field.repl:defer_execute(code)
end

return Repl
