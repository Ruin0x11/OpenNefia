local Event = require("api.Event")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Effect = require("mod.elona.api.Effect")
local Log = require("api.Log")
local World = require("api.World")
local Ui = require("api.Ui")
local Enum = require("api.Enum")
local Skill = require("mod.elona_sys.api.Skill")
local Const = require("api.Const")
local Weather = require("mod.elona.api.Weather")
local IItemFood = require("mod.elona.api.aspect.IItemFood")

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

local function make_potion_dip_sourceable(item)
   if item:has_category("elona.drink") then
      item.can_dip_source = true
   end
end

Event.register("base.on_item_instantiated", "Make potion dip sourceable", make_potion_dip_sourceable)

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
         item.proto.on_drink(item, drink_params)
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

local function check_item_cooldown_time(item, params, result)
   -- >>>>>>>> shade2/action.hsp:1719 	if iBit(iPeriod,ci)=true{ ...
   if item.cooldown_hours then
      assert(type(item.cooldown_hours) == "number")
      item.next_use_date = item.next_use_date or 0
      local date_hours = World.date_hours()
      if date_hours < item.next_use_date then
         Gui.mes("action.use.useable_again_at", Ui.format_date(item.next_use_date, true))
         return "player_turn_query", "blocked"
      end
      local sep = item:separate()
      sep.next_use_date = date_hours + (item:calc("cooldown_hours") or 0)
   end
   -- <<<<<<<< shade2/action.hsp:1723 		} ..
end
Event.register("elona_sys.on_item_use", "Check item cooldown time and maybe prevent use", check_item_cooldown_time, { priority = 10000})

local function proc_item_eaten_is_poisoned(food, params, result)
   -- >>>>>>>> shade2/item.hsp:1140 	if iBit(iPoisonBlend,ci)=true{ ...
   if not food:calc("is_mixed_with_poison") then
      return result
   end

   local chara = params.chara

   if chara:is_in_fov() then
      Gui.mes("food.effect.poisoned.text", chara)
      Gui.mes("food.effect.poisoned.dialog", chara)
   end

   chara:damage_hp(Rand.rnd(250) + 250, "elona.poison")

   if not Chara.is_alive(chara) then
      if not chara:is_player() and chara:relation_towards(Chara.player()) >= Enum.Relation.Neutral then
         Effect.modify_karma(Chara.player(), -1)
      end
      return result, "blocked"
   end
   -- <<<<<<<< shade2/item.hsp:1150 		} ..
end
Event.register("elona_sys.on_item_eat", "Proc is poisoned eating effect", proc_item_eaten_is_poisoned, { priority = 120000 })

local function proc_item_eaten_is_spiked_with_love_potion(food, params, result)
   -- >>>>>>>> shade2/item.hsp:1152 	if iBit(iLoveBlend,ci)=true{ ...
   if not food:calc("is_spiked_with_love_potion") then
      return result
   end

   local chara = params.chara

   if chara:is_player() then
      Gui.mes("food.effect.spiked.self")
   else
      Gui.mes_c("food.effect.spiked.other", "SkyBlue", chara)
      Skill.modify_impression(chara, 30)
      Effect.modify_karma(Chara.player(), -10)
      Effect.love_miracle(chara)
   end

   chara:apply_effect("elona.dimming", 500)
   chara:set_emotion_icon("elona.heart", 3)
   -- <<<<<<<< shade2/item.hsp:1163 	} ..
end
Event.register("elona_sys.on_item_eat", "Proc is spiked with love potion eating effect", proc_item_eaten_is_spiked_with_love_potion, { priority = 130000 })

local function make_bed_useable(item)
   if item:has_category("elona.furniture_bed") then
      item.can_use = true
   end
end
Event.register("base.on_item_instantiated", "Make bed useable", make_bed_useable)

local function use_bed(item, params)
   -- >>>>>>>> shade2/action.hsp:1732 	if iTypeMinor(ci)=fltBed{ ...
   if not item:has_category("elona.furniture_bed") then
      return
   end
   -- <<<<<<<< shade2/action.hsp:1735 		} ..

   if save.elona_sys.awake_hours < Const.SLEEP_THRESHOLD_LIGHT then
      Gui.mes("action.use.not_sleepy")
      return "player_turn_query"
   end

   params.chara:start_activity("elona.preparing_to_sleep", { bed = item })
end
Event.register("elona_sys.on_item_use", "Use bed", use_bed, { priority = 200000 })

local function turn_to_jerky(item, params, result)
   local map = params.owning_map
   if not map then
      return result
   end
   
   if not (item._id == "elona.corpse" and map:tile(item.x, item.y).kind == Enum.TileRole.Dryground) then
      return result
   end

   if Weather.is("elona.sunny") then
      Gui.mes("misc.corpse_is_dried_up", item:build_name(), item.amount)
      local food = item:get_aspect_or_default(IItemFood)
      item.image = "elona.item_jerky"
      item:change_prototype("elona.jerky")
      food.spoilage_date = World.date_hours() + 2160
      food.food_type = nil
      food.food_quality = 5
      item:refresh_cell_on_map()
   end

   return result, Event.Result.Blocked
end
Event.register("elona.on_item_rot", "Turn corpses to jerky on drygrounds", turn_to_jerky, { priority = 50000 })

local function default_item_rot(item, params)
   if params.owning_chara then
      if params.owning_chara:is_in_player_party() then
         Gui.mes("misc.get_rotten", item:build_name(), item.amount)
      end
   end

   local food = item:get_aspect(IItemFood)
   food:rot(item)

   if params.owning_map then
      item:refresh_cell_on_map()
   end
end
Event.register("elona.on_item_rot", "Default item rot", default_item_rot, { priority = 100000 })
