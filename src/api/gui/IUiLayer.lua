local Env = require("api.Env")
local Event = require("api.Event")
local Log = require("api.Log")
local IDrawable = require("api.gui.IDrawable")
local IInput = require("api.gui.IInput")

local draw = require("internal.draw")

local IUiLayer

-- TODO: z_order should be a class variable, or at least configurable,
-- instead of having to specify it at the call site every time.

--- Starts drawing this UI layer and switches input focus to it.
---
--- @treturn[opt] any The value returned by the layer's `update`
--- function. Always nil if the layer was canceled, but not
--- necessarily non-nil if it was not canceled.
--- @treturn[opt] string Equals "canceled" if the layer was canceled
--- out of.
local function query(self, z_order)
   class.assert_is_an(IUiLayer, self)

   local dt = 0
   local abort = false

   draw.push_layer(self, z_order)

   local ok, result = pcall(function() return self:on_query() end)
   if not ok or (ok and result == false) then
      draw.pop_layer()
      if not ok then
         error(result)
      end
      return
   end

   local success, res, canceled

   if Env.is_headless() then
      res, canceled = Env.pop_ui_result()
      Log.info("Returning UI result: %s %s", inspect(res), tostring(canceled))
   else
      while true do
         if abort then
            -- BUG: This should remove the layer with the error instead
            -- of the topmost layer always.
            Log.error("Draw error encountered, removing layer.")
            break
         end

         success, res, canceled = xpcall(
            function()
               local ran = self:run_actions(dt)
               return self:update(dt, ran)
            end,
            debug.traceback)
         if not success then
            Log.error("Error on query: %s", res)
            break
         end
         if res or canceled then break end
         dt, abort = coroutine.yield()
      end
   end

   ok, result = pcall(function()
         self:halt_input()
         self:release()
   end)

   if not ok then
      Log.error("Error releasing UI layer: %s", result)
   end

   draw.pop_layer()

   return res, canceled
end

IUiLayer = class.interface("IUiLayer",
                           {
                              relayout = "function",
                              make_keymap = "function",
                              query = { default = query },
                              release = { default = function() end },
                              on_query = { default = function() end },
                              on_hotload_layer = { default = function() end },
                           },
                           { IDrawable, IInput })

return IUiLayer
