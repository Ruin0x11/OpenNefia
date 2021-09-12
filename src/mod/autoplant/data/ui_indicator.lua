local Autoplant = require("mod.autoplant.api.Autoplant")

local function indicator_autoplant(player)
   if not Autoplant.is_enabled() then
      return
   end

   return {
      text = "autoplant.indicator.text"
   }
end

data:add {
   _type = "base.ui_indicator",
   _id = "autoplant",

   indicator = indicator_autoplant
}
