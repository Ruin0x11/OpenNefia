local Gui = require("api.Gui")
local Item = require("api.Item")
local SkillCheck = require("mod.elona.api.SkillCheck")
local Rand = require("api.Rand")
local Magic = require("mod.elona_sys.api.Magic")
local Skill = require("mod.elona_sys.api.Skill")
local Effect = require("mod.elona.api.Effect")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Itemgen = require("mod.elona.api.Itemgen")
local Charagen = require("mod.elona.api.Charagen")
local IItemAncientBook = require("mod.elona.api.aspect.IItemAncientBook")

local ItemFunction = {}

function ItemFunction.proc_fall_into_well(item, chara)
   -- >>>>>>>> shade2/proc.hsp:1392 	if cc!pc :if rnd(15)=0{ ...
   if chara:is_player() then
      return false
   end

   if not Rand.one_in(15) then
      return false
   end

   Gui.mes("action.drink.well.effect.falls.text", chara)
   chara:mes("action.drink.well.effect.falls.dialog")

   if SkillCheck.is_floating(chara) then
      Gui.mes("action.drink.well.effect.falls.floats", chara)
   else
      chara:damage_hp(math.max(chara.hp, 9999), "elona.trap")
   end

   return true
   -- <<<<<<<< shade2/proc.hsp:1398 	if iId(ci)=idHolyWell:if rnd(2)=0:call effect,(ef ..
end

function ItemFunction.drink_from_well(item, chara)
   -- >>>>>>>> shade2/proc.hsp:1401 	if p>70 { ...
   local map = chara:current_map()
   local event = Rand.rnd(100)

   if event > 70 then
      local effect_id = Rand.choice {
         "elona.effect_sleep",
         "elona.effect_paralyze",
         "elona.effect_blind",
         "elona.effect_confuse",
         "elona.effect_poison"
      }
      Magic.cast(effect_id, { target = chara, power = 100 })
   elseif event > 55 then
      local amount = Rand.rnd(chara:skill_level("elona.detection") / 2 * 50 + 100) + 1
      Item.create("elona.gold_piece", chara.x, chara.y, { amount = amount }, map)
      Gui.mes("action.drink.well.effect.finds_gold", chara)
   elseif event > 45 then
      local skill_id = Rand.choice(Skill.iter_base_attributes())._id
      if Rand.rnd(5) > 2 then
         Skill.gain_fixed_skill_exp(chara, skill_id, 1000)
      else
         Skill.gain_fixed_skill_exp(chara, skill_id, -1000)
      end
   elseif event > 40 then
      if chara.level < 5 then
         return
      end
      if chara:is_in_fov() then
         Gui.mes("action.drink.well.effect.pregnancy", chara)
      end
      Effect.impregnate(chara)
   elseif event > 35 then
      Gui.mes("action.drink.well.effect.monster")
      for _ = 1, 1 + Rand.rnd(3) do
         local filter = {
            level = Calc.calc_object_level(chara:calc("level") * 3 / 2 + 3),
            quality = Calc.calc_object_quality(Enum.Quality.Normal)
         }
         Charagen.create(chara.x, chara.y, filter, map)
      end
   elseif event > 33 then
      Magic.cast("elona.effect_gain_potential", { target = chara })
   elseif event > 20 then
      Magic.cast("elona.mutation", { target = chara })
   elseif event == 0 then
      if not Rand.one_in(save.elona.well_wish_count+1) then
         Gui.mes_c("action.drink.well.effect.wish_too_frequent", "Yellow")
         return
      end
      save.elona.well_wish_count = save.elona.well_wish_count+1
      Magic.cast("elona.wish", { target = chara })
   else
      if chara:is_player() then
         Gui.mes("action.drink.well.effect.default")
      end
   end
   -- <<<<<<<< shade2/proc.hsp:1444 	if cc=pc:txt lang("この水は清涼だ。","Phew, fresh water t ..
end

function ItemFunction.read_ancient_book(item, params)
   local aspect = assert(item:get_aspect(IItemAncientBook))

   -- >>>>>>>> shade2/proc.hsp:1168 *readSpellbook ..
   if aspect:calc(item, "is_decoded") then
      Gui.mes("action.read.book.already_decoded")
      return "turn_end"
   end

   local chara = params.chara or item:get_owning_chara()

   if chara:has_effect("elona.blindness") then
      Gui.mes_visible("action.read.cannot_see", chara)
      return "turn_end"
   end

   -- <<<<<<<< shade2/proc.hsp:1176 		cRowAct(cc)=rowActRead ..

   -- >>>>>>>> shade2/proc.hsp:1180 			if iId(ci)=idMageBook{ ..
   local base_diff = aspect:calc(item, "difficulty")
   local difficulty = 50 + base_diff * 50 + base_diff * base_diff * 20
   -- <<<<<<<< shade2/proc.hsp:1182 			}else{ ..

   -- >>>>>>>> shade2/proc.hsp:1186 		cActionPeriod(cc)=p/(2+sLiteracy(pc))+1 ..
   local sep = item:separate()
   assert(Item.is_alive(sep))
   chara:set_item_using(sep)

   local turns = difficulty / (2 * chara:skill_level("elona.literacy")) + 1
   chara:start_activity("elona.reading_ancient_book", { ancient_book = sep }, turns)

   return "turn_end"
   -- <<<<<<<< shade2/proc.hsp:1191 		} ..
end

return ItemFunction
