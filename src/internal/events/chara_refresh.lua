local Event = require("api.Event")

local function on_recruited_as_ally(chara)
   -- >>>>>>>> shade2/adv.hsp:12 	cRole(rc)=false ..
   chara.roles = {}
   chara:reset("is_quest_target", false)
   chara:reset("is_not_targeted_by_ai", false)
   chara:reset("is_summoned", false)
   chara:reset("is_only_in_christmas", false)
   -- <<<<<<<< shade2/adv.hsp:17 	cBitMod cFestival,rc,false ..
end
Event.register("base.on_recruited_as_ally", "Clear flags", on_recruited_as_ally)
