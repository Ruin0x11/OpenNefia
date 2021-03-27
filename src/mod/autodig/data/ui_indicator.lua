local Autodig = require("mod.autodig.api.Autodig")

local function indicator_autodig(player)
   if not Autodig.is_enabled() then
      return
   end

   return {
      text = "autodig.indicator.text"
   }
end

data:add {
   _type = "base.ui_indicator",
   _id = "autodig",

   ordering = 1000000,
   indicator = indicator_autodig
}
