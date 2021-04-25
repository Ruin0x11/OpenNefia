local IAquesTalkConfig = require("mod.aquestalk.api.aspect.IAquesTalkConfig")

local AquesTalkConfigAspect = class.class("AquesTalkConfigAspect", IAquesTalkConfig)

function AquesTalkConfigAspect:init(chara, params)
   if params.bas then
      self.bas = params.bas
   else
      if chara:calc("gender") == "male" then
         self.bas = "m1e"
      else
         self.bas = "f1e"
      end
   end
   self.spd = params.spd or config.aquestalk.default_spd
   self.vol = params.vol or config.aquestalk.default_vol
   self.pit = params.pit or config.aquestalk.default_pit
   self.acc = params.acc or config.aquestalk.default_acc
   self.lmd = params.lmd or config.aquestalk.default_lmd
   self.fsc = params.fsc or config.aquestalk.default_fsc
end

return AquesTalkConfigAspect
