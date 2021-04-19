local ICharaSandBag = require("mod.elona.api.aspect.ICharaSandBag")
local Event = require("api.Event")
local Rand = require("api.Rand")
local Gui = require("api.Gui")
local I18N = require("api.I18N")

local function remove_sandbag(chara)
   local sand_bag = chara:get_aspect(ICharaSandBag)
   if sand_bag then
      sand_bag:release_from_sand_bag(chara)
   end
end
Event.register("base.on_recruited_as_ally", "Aspect: ICharaSandBag remove", remove_sandbag)

local function update_sandbag_y_offset(chara)
   if chara:calc_aspect(ICharaSandBag, "is_hung_on_sand_bag") then
      chara:mod("y_offset", -32, "set")
   end
end
Event.register("base.on_refresh", "Update draw offset for sandbag", update_sandbag_y_offset)

local function proc_sandbag(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1499 		if cBit(cSandBag,tc):cHp(tc)=cMhp(tc) ..
   if chara.hp < 0 and chara:calc_aspect(ICharaSandBag, "is_hung_on_sand_bag") then
      chara.hp = chara:calc("max_hp")
   end
   -- <<<<<<<< shade2/chara_func.hsp:1499 		if cBit(cSandBag,tc):cHp(tc)=cMhp(tc) ..
end
Event.register("base.after_chara_damaged", "Proc sandbag", proc_sandbag)

local function block_if_sandbag(chara, params, result)
   -- >>>>>>>> shade2/ai.hsp:29 	if cBit(cSandBag,cc){ ...
   if chara:calc_aspect(ICharaSandBag, "is_hung_on_sand_bag") then
      if chara:is_in_fov() then
         if Rand.one_in(30) then
            Gui.mes_c(I18N.quote_speech("action.npc.sand_bag", chara), "Talk")
         end
      end
      chara:set_aggro(chara:get_target(), 0)
      return true, "blocked"
   end

   return result
   -- <<<<<<<< shade2/ai.hsp:32 		} ..
end
Event.register("elona.before_default_ai_action", "Block if hung on sandbag", block_if_sandbag, {priority = 5000})

local function proc_sandbag_talk(chara, params)
   -- >>>>>>>> shade2/chara_func.hsp:1769 	if cBit(cSandBag,tc):if sync(tc):txt "("+dmg+")"+ ..
   if chara:calc_aspect(ICharaSandBag, "is_hung_on_sand_bag") then
      if chara:is_in_fov() then
         local mes = ("(%d)%s"):format(params.damage, I18N.space())
         Gui.mes(mes)
         if Rand.one_in(20) then
            Gui.mes_c(I18N.quote_speech("damage.sand_bag"), "Talk")
         end
      end
   end
   -- <<<<<<<< shade2/chara_func.hsp:1769 	if cBit(cSandBag,tc):if sync(tc):txt "("+dmg+")"+ ..
end

Event.register("base.after_chara_damaged", "Proc sandbag talk", proc_sandbag_talk, {priority = 500000})
