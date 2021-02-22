local Gui = require("api.Gui")

local ExampleApi = {}

function ExampleApi.do_something(arg)
   -- Your code here.
   if arg then
      Gui.mes("github.greeting_custom", arg)
   else
      Gui.mes("github.greeting")
   end
end

return ExampleApi
