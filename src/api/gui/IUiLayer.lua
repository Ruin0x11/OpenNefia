local Log = require("api.Log")
local IDrawable = require("api.gui.IDrawable")
local IInput = require("api.gui.IInput")

local internal = require("internal")

local IUiLayer

local function query(self)
   class.assert_is_an(IUiLayer, self)

   local dt = 0

   internal.draw.push_layer(self)

   self:on_query()

   local success, res, canceled
   while true do
      success, res, canceled = pcall(function()
            local ran = self:run_actions(dt)
            return self:update(dt, ran)
      end)
      if not success then
         Log.error("Error on query: %s", res)
         break
      end
      if res or canceled then break end
      dt = coroutine.yield()
   end

   self:halt_input()

   internal.draw.pop_layer()

   return res, canceled
end

IUiLayer = class.interface("IUiLayer",
                 {
                    relayout = "function",
                    query = { default = query },
                    on_query = { default = function() end },
                    on_hotload_layer = { default = function() end },
                 },
                 { IDrawable, IInput })

return IUiLayer
