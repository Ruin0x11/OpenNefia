local Event = require("api.Event")
local config = require("internal.config")

local function impl_debug_hp_always_full(chara, params, result)
   -- >>>>>>>> shade2/chara_func.hsp:1476 		if dbg_hpAlwaysFull@:cHP(tc)=cMHP(tc) ...
   if chara:is_player() and config.base.debug_hp_always_full then
      chara.hp = chara:calc("max_hp")
   end
   -- <<<<<<<< shade2/chara_func.hsp:1476 		if dbg_hpAlwaysFull@:cHP(tc)=cMHP(tc) ..

   return result
end
Event.register("base.after_chara_damaged", "Implement config.base.hp_always_full", impl_debug_hp_always_full)
