local Event = require("api.Event")

local enabled = false

local Debug = {}

function Debug.print(...)
   if not enabled then
      return
   end
   print(...)
end

function Debug._ppr(...)
   if not enabled then
      return
   end
   _ppr(...)
end

function Debug.print_end(e)
   enabled = e or false
end

Event.register("base.on_hotload_end",
               "enable Debug.print",
               function()
                  enabled = true
               end)

return Debug
