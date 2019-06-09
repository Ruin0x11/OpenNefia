local IDrawable = require("api.gui.IDrawable")
local IInput = require("api.gui.IInput")

local internal = require("internal")

local IUiLayer

local function query(self)
   assert_is_an(IUiLayer, self)

   local dt = 0

   internal.draw.push_layer(self)

   local res, canceled
   while true do
      local ran = self:run_actions(dt)
      res, canceled = self:update(dt, ran)
      if res or canceled then break end
      dt = coroutine.yield()
   end

   self:halt_input()

   internal.draw.pop_layer()

   return res, canceled
end

IUiLayer = interface("IUiLayer",
                 {
                    relayout = "function",
                    query = { default = query },
                 },
                 { IDrawable, IInput })

return IUiLayer
