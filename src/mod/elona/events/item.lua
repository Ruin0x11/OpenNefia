local Event = require("api.Event")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Effect = require("mod.elona.api.Effect")
local Log = require("api.Log")

local function proc_sandbag(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1499 		if cBit(cSandBag,tc):cHp(tc)=cMhp(tc) ..
   if chara.hp < 0 and chara:calc("is_hung_on_sandbag") then
      chara.hp = chara:calc("max_hp")
   end
   -- <<<<<<<< shade2/chara_func.hsp:1499 		if cBit(cSandBag,tc):cHp(tc)=cMhp(tc) ..
end

Event.register("base.after_chara_damaged",
               "Proc sandbag", proc_sandbag)

local function proc_sandbag_talk(chara, params)
   -- >>>>>>>> shade2/chara_func.hsp:1769 	if cBit(cSandBag,tc):if sync(tc):txt "("+dmg+")"+ ..
   if chara:calc("is_hung_on_sandbag") then
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

Event.register("base.after_chara_damaged",
               "Proc sandbag talk", proc_sandbag_talk, {priority = 500000})

local function make_potion_throwable(item)
   if item:has_category("elona.drink") then
      item.can_throw = true
   end
end

Event.register("base.on_item_instantiated", "Make potion throwable", make_potion_throwable)

local function on_potion_thrown(item, params, result)
   if result or not item:has_category("elona.drink") or item.proto.on_throw then
      return result
   end

   -- >>>>>>>> shade2/action.hsp:60 			snd seCrush2 ...
   Gui.play_sound("base.crush2", params.x, params.y)
   -- <<<<<<<< shade2/action.hsp:60 			snd seCrush2 ..

   -- >>>>>>>> shade2/action.hsp:62 		if map(tlocX,tlocY,1)!0{ ...
   local chara = params.chara
   local map = chara:current_map()
   local target = Chara.at(params.x, params.y, map)
   if target then
      Gui.mes("action.throw.hits", target)
      Effect.get_wet(target, 25)
      target:interrupt_activity()
      -- <<<<<<<< shade2/action.hsp:65 			rowAct_Check tc ...
      -- >>>>>>>> shade2/action.hsp:78 			if tc>=maxFollower :hostileAction cc,tc ...
      if not chara:is_in_same_party(target) then
         chara:act_hostile_towards(target)
      end
      if item.proto.on_drink then
         local drink_params = {
            chara = target,
            item = item,
            triggered_by = "potion_thrown"
         }
         item:on_drink(drink_params)
      else
         Log.warn("Potion mef '%s' missing 'on_drink' callback", item.proto._id)
      end
      return "turn_end"
      -- <<<<<<<< shade2/action.hsp:83 			goto *turn_end ..
   end

   -- >>>>>>>> shade2/action.hsp:111 		efP=50+sThrow(cc)*10 ...
   Effect.create_potion_puddle(params.x, params.y, item, chara)
   return "turn_end"
   -- <<<<<<<< shade2/action.hsp:115 		goto *turn_end ..
end

Event.register("elona_sys.on_item_throw", "On potion thrown", on_potion_thrown)
