local Gui = require("api.Gui")
local Input = require("api.Input")
local Item = require("api.Item")
local Skill = require("mod.elona_sys.api.Skill")
local elona_Item = require("mod.elona.api.Item")
local Enum = require("api.Enum")
local Rand = require("api.Rand")
local Calc = require("mod.elona.api.Calc")
local Effect = require("mod.elona.api.Effect")
local Itemgen = require("mod.tools.api.Itemgen")
local ItemMaterial = require("mod.elona.api.ItemMaterial")
local AliasPrompt = require("api.gui.AliasPrompt")
local I18N = require("api.I18N")
local IItemEnchantments = require("api.item.IItemEnchantments")

local Smithing = {}

function Smithing.calc_hammer_activity_turns(act, params, chara)
   return 25 - chara:trait_level("smithing.blacksmith") * 5 + Rand.rnd(11)
end

local function item_type_prompt(choices)
   return function()
      Gui.mes("smithing.blacksmith_hammer.create.prompt")
      local map = function(c) return { text = "smithing.blacksmith_hammer.create.item_types." .. c, data = c } end
      local choices = fun.iter(choices)
         :map(map)
         :to_list()

      local result, canceled = Input.prompt(choices)
      if canceled then
         return nil, canceled
      end
      return choices[result.index].data
   end
end

Smithing.prompt_weapon_type = item_type_prompt {
   "elona.equip_melee_broadsword",
   "elona.equip_melee_long_sword",
   "elona.equip_melee_short_sword",
   "elona.equip_melee_lance",
   "elona.equip_melee_halberd",
   "elona.equip_melee_hand_axe",
   "elona.equip_melee_axe",
   "elona.equip_melee_scythe",
}

Smithing.prompt_armor_type = item_type_prompt {
   "elona.equip_body_mail",
   "elona.equip_head_helm",
   "elona.equip_shield_shield",
   "elona.equip_leg_heavy_boots",
   "elona.equip_wrist_gauntlet"
}

function Smithing.calc_required_hammer_levels_to_next_bonus(hammer)
   local bonus = hammer
   if type(hammer) == "table" then
      bonus = hammer.bonus
   end
   return 2000 * (bonus + 1)
end

function Smithing.can_smith_item(item, hammer, selected_items)
   if item.own_state == Enum.OwnState.NotOwned or item.own_state == Enum.OwnState.Unobtainable then
      return false
   end

   if fun.iter(selected_items):any(function(i) return item.uid == i.uid end) then
      return false
   end

   -- >>>>>>>> oomSEST/src/southtyris.hsp:104957 			reftype@m18 = refitem(iId(__invNo), 5, __invNo) ..
   if item._id == "elona.broken_sword" then
      return true
   elseif elona_Item.is_equipment(item) then
      return true
   elseif item._id == "elona.remains_skin" then
      return true
   elseif item._id == "smithing.blacksmith_hammer" then
      if hammer.params.hammer_level >= Smithing.calc_required_hammer_levels_to_next_bonus(item.bonus) and hammer.uid == item.uid then
         return true
      end
   elseif item:has_category("elona.furniture") and not item.is_no_drop then
      return true
   end
   return false
   -- <<<<<<<< oomSEST/src/southtyris.hsp:104977 			goto *label_1958 ..
end

function Smithing.can_use_item_as_weapon_material(item, hammer, selected_items)
   if item.own_state == Enum.OwnState.NotOwned or item.own_state == Enum.OwnState.Unobtainable then
      return false
   end

   if fun.iter(selected_items):any(function(i) return item.uid == i.uid end) then
      return false
   end

   -- >>>>>>>> oomSEST/src/southtyris.hsp:104980 			reftypeminor@m18 = refitem(iId(__invNo), 9, __i ..
   if item:has_category("elona.ore_valuable") then
      return true
   elseif item._id == "elona.vanilla_rock" then
      return true
   elseif item._id == "elona.remains_skin" and item.params.chara_id then
      local chara_data = data["base.chara"]:ensure(item.params.chara_id)
      if table.set(chara_data.tags or {})["dragon"] then
         return true
      end
   end
   return false
   -- <<<<<<<< oomSEST/src/southtyris.hsp:104991 			goto *label_1958 ..
end

function Smithing.can_use_item_as_furniture_material(item, hammer, selected_items)
   if item.own_state == Enum.OwnState.NotOwned or item.own_state == Enum.OwnState.Unobtainable then
      return false
   end

   if fun.iter(selected_items):any(function(i) return item.uid == i.uid end) then
      return false
   end

   -- >>>>>>>> oomSEST/src/hammer.hsp:892 		if (iId(__invNo) == iId_skin | iId(__invNo) == i ..
   if item._id == "elona.remains_skin" or item._id == "elona.remains_bone" or item._id == "elona.corpse" then
      if item.params.chara_id or item.is_precious then
         return true
      end
   end

   return false
   -- <<<<<<<< oomSEST/src/hammer.hsp:896 		} ..
end

function Smithing.on_use_blacksmith_hammer(hammer, chara)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:83523 		cw = ci ..
   Gui.play_sound("base.inv")
   local params = {hammer = hammer, selected_items = {}}
   local result, canceled = Input.query_item(chara, "smithing.hammer_target", { params=params })
   if canceled then
      return false
   end

   local item = result.result:separate()

   if item._id == "elona.broken_sword" then
      local anvil = Item.find("elona.anvil", "all")
      local furnace = Item.find("elona.furnace", "all")
      if not (anvil and furnace) then
         Gui.mes("smithing.blacksmith_hammer.requires_anvil_and_furnace")
         return false
      end

      local item_type, canceled = Smithing.prompt_weapon_type()
      if canceled then
         return false
      end

      params = {hammer = hammer, selected_items = {item}}
      result, canceled = Input.query_item(chara, "smithing.hammer_weapon_material", { params=params })
      if canceled then
         return false
      end

      -- >>>>>>>> oomSEST/src/southtyris.hsp:98505                 if (reftypeminor == 77001 | iId(ci ..
      local material_item = result.result:separate()
      chara:start_activity("smithing.create_equipment", {hammer=hammer, categories={item_type}, target_item=item, material_item=material_item})
      return true
      -- <<<<<<<< oomSEST/src/southtyris.hsp:98515             } ..
   elseif item._id == "elona.remains_skin" then
      local anvil = Item.find("elona.anvil", "all")
      local furnace = Item.find("elona.furnace", "all")
      if not (anvil and furnace) then
         Gui.mes("smithing.blacksmith_hammer.requires_anvil_and_furnace")
         return false
      end

      local item_type, canceled = Smithing.prompt_armor_type()
      if canceled then
         return false
      end

      -- >>>>>>>> oomSEST/src/southtyris.hsp:98505                 if (reftypeminor == 77001 | iId(ci ..
      chara:start_activity("smithing.create_equipment", {hammer=hammer, categories={item_type}, target_item=item, material_item=nil})
      return true
      -- <<<<<<<< oomSEST/src/southtyris.hsp:98515             } ..
   elseif item:has_category("elona.furniture") then
      -- >>>>>>>> oomSEST/src/hammer.hsp:148 					anvil = 0 ..
      local anvil = Item.find("elona.anvil", "all")
      if anvil == nil then
         Gui.mes("smithing.blacksmith_hammer.requires_anvil")
         return false
      end

      Gui.mes("smithing.blacksmith_hammer.repair_furniture.prompt")

      params = { hammer = hammer, selected_items = {item} }
      result, canceled = Input.query_item(chara, "smithing.hammer_furniture_material", { params=params })
      if canceled then
         return false
      end
      -- <<<<<<<< oomSEST/src/hammer.hsp:166 					invctrl(1) = 3 ..

      local material_item = result.result:separate()
      chara:start_activity("smithing.repair_furniture", {hammer=hammer, target_item=item, material_item=material_item})
      return true
   elseif item._id == "smithing.blacksmith_hammer" then
      -- >>>>>>>> oomSEST/src/southtyris.hsp:98447                     notfound = 1 ..
      if item.params.hammer_level < Smithing.calc_required_hammer_levels_to_next_bonus(item) then
         Gui.mes("smithing.blacksmith_hammer.upgrade_hammer.is_not_upgradeable")
         return false
      end
      -- <<<<<<<< oomSEST/src/southtyris.hsp:98456                     cQualityOfPerformance(cc) = 6 ..

      chara:start_activity("smithing.upgrade_hammer", {hammer=item})
      return true
   else
      -- >>>>>>>> oomSEST/src/southtyris.hsp:98458                     notfound = 1 ..
      local power = 0
      if item.bonus >= 0 then
         local anvil = Item.find("elona.anvil", "all")
         if anvil == nil then
            Gui.mes("smithing.blacksmith_hammer.requires_anvil")
            return false
         end

         power = math.min(math.floor(hammer.params.hammer_level * 9 / 20), 900)
         if hammer.params.hammer_level >= 2000 then
            power = power + 50
         end
         if hammer.bonus > 0 then
            power = power + 50
         end
         if not (hammer.params.hammer_level >= 21 and item.bonus < power) then
            Gui.mes("smithing.blacksmith_hammer.repair_equipment.no_repairs_are_necessary")
            return false
         end
      end

      chara:start_activity("smithing.repair_equipment", {hammer=hammer, target_item=item, power=power})
      return true
      -- <<<<<<<< oomSEST/src/southtyris.hsp:98491                     cQualityOfPerformance(cc) = 2 ..
   end
   -- <<<<<<<< oomSEST/src/southtyris.hsp:83534 		goto *label_1454 ..
end

function Smithing.calc_smith_extend_chance(hammer, extend)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:98541 			if (rnd(limitmin(200 + extend * 50 - iEnhanceme ..
   return math.max(200 + extend * 50 - hammer.bonus * 100, 1)
   -- <<<<<<<< oomSEST/src/southtyris.hsp:98541 			if (rnd(limitmin(200 + extend * 50 - iEnhanceme ..
end

-- >>>>>>>> oomSEST/src/southtyris.hsp:104907 #deffunc modexpsmith int __fff, int __ggg ..
function Smithing.gain_hammer_experience(hammer, amount)
   amount = math.floor(amount)

   local level = hammer.params.hammer_level
   local cur_exp = hammer.params.hammer_experience
   local req_exp = Calc.calc_living_weapon_required_exp(level)

   if level >= Smithing.calc_required_hammer_levels_to_next_bonus(hammer) then
      hammer.params.hammer_experience = (cur_exp + amount) % req_exp
      return false
   end

   if level <= Smithing.calc_required_hammer_levels_to_next_bonus(hammer.bonus-1) then
      amount = amount * 100 * hammer.bonus
   end

   if cur_exp < req_exp then
      cur_exp = math.max(cur_exp, 0)
      hammer.params.hammer_experience = cur_exp + amount
   end

   if hammer.params.hammer_experience >= req_exp then
      hammer.params.hammer_level = level + 1
      hammer.params.hammer_experience = 0
      hammer.params.hammer_total_uses = 0
      Gui.play_sound("base.ding3")
      Gui.mes_c("smithing.blacksmith_hammer.skill_increases", "Green")
   end

   local exp_perc = (hammer.params.hammer_experience * 100.0) / Calc.calc_living_weapon_required_exp(hammer.params.hammer_level)
   exp_perc = ("%3.6f"):format(exp_perc):sub(1, 6)
   Gui.mes(("%s(Lv: %d Exp:%s%%)"):format(I18N.space(), hammer.params.hammer_level, string.right_pad(tostring(exp_perc), 6)))

   return true
end
-- <<<<<<<< oomSEST/src/southtyris.hsp:104931 	return 1 ..

function Smithing.material_for_chara(chara_id)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:98595             s = refchara(iSubname(ci), 8, 1) ..
   local chara_data = data["base.chara"]:ensure(chara_id)

   if table.set(chara_data.tags or {})["dragon"] then
      return "elona.dragon_scale"
   elseif chara_id == "elona.steel_golem" then
      return "elona.steel"
   elseif chara_id == "elona.golden_golem" or chara_id == "elona.golden_armor" then
      return "elona.gold"
   elseif chara_id == "elona.mithril_golem" then
      return "elona.mithril"
   elseif chara_id == "elona.adamantium_golem" then
      return "elona.adamantium"
   elseif chara_id == "elona.living_armor" then
      return "elona.bronze"
   elseif chara_id == "elona.steel_mass" then
      return "elona.iron"
   elseif chara_id == "elona.death_armor" then
      return "elona.titanum"
   elseif chara_id == "elona.wisp" or chara_id == "elona.shining_hedgehog" then
      return "elona.ether"
   end
   return "elona.scale"
   -- <<<<<<<< oomSEST/src/southtyris.hsp:98616             } ..
end

function Smithing.material_for_ore(item_id)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:98583             if (iId(ci) == 42) { ..
   if item_id == "elona.raw_ore_of_diamond" then
      return "elona.diamond"
   elseif item_id == "elona.raw_ore_of_emerald" then
      return "elona.emerald"
   elseif item_id == "elona.raw_ore_of_mica" then
      return "elona.mica"
   elseif item_id == "elona.raw_ore_of_rubynus" then
      return "elona.rubynus"
   end
   -- <<<<<<<< oomSEST/src/southtyris.hsp:98591             } ..
   return "elona.sand"
end

function Smithing.random_item_filter_and_material(hammer, material, categories, quality)
   local map = assert(hammer:containing_map())
   local item_material = "elona.sand"
   local item_quality = Calc.calc_object_quality(Enum.Quality.Normal, map)

   if material._id == "elona.vanilla_rock" then
      item_material = "elona.adamantium"
      local quality_base = math.clamp(hammer.params.hammer_level * 2 / 25, Enum.Quality.Normal, Enum.Quality.Great)
      item_quality = Calc.calc_object_quality(quality_base, map)
   elseif material:has_category("elona.ore_valuable") then
      item_material = Smithing.material_for_ore(material._id)

      local quality_base = quality / (material.value * (11 ^ 2) / math.max(hammer.params.hammer_level * 2 / 25, 1))

      item_quality = Calc.calc_object_quality(math.clamp(quality_base, Enum.Quality.Normal, Enum.Quality.Great), map)
   elseif material._id == "elona.remains_skin" then
      item_material = Smithing.material_for_chara(material.params.chara_id)

      local quality_base = quality / math.max(material.value * 20 / math.max(hammer.params.hammer_level * 2 / 25, 1))

      item_quality = Calc.calc_object_quality(math.clamp(quality_base, Enum.Quality.Normal, Enum.Quality.Great), map)
   end

   local max_quality = Enum.Quality.Great
   if hammer:calc("curse_state") == Enum.CurseState.Cursed then
      max_quality = Enum.Quality.Good
   elseif hammer:calc("curse_state") == Enum.CurseState.Doomed then
      max_quality = Enum.Quality.Normal
   end
   item_quality = math.min(item_quality, max_quality)

   local filter = {
      level = hammer.params.hammer_level,
      quality = item_quality,
      categories = categories,
      no_stack = true
   }

   return filter, item_material
end

--- Returns a merged enchantment with a total power greater than zero, not
--- including power from enchantments added by the item's material.
function Smithing.extendable_enchantment(item)
   local filter = function(enc) return enc.source ~= "material" end
   local merged_encs = IItemEnchantments.calc_total_enchantment_powers(item:iter_base_enchantments():filter(filter))
   return fun.iter(merged_encs):filter(function(merged_enc) return merged_enc.total_power > 0 end):nth(1)
end

function Smithing.create_equipment(hammer, chara, target_item, material, categories, extend)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:98549 		quality = 0 ..
   local quality = 0

   quality = quality + target_item:calc("value")
   target_item:remove(1)

   if material then
      quality = quality + material:calc("value")
      material:remove(1)
   else
      material = target_item
   end

   Rand.set_seed(hammer.params.hammer_level * 1000000 + hammer.params.hammer_experience)

   if hammer.params.hammer_level ^ 3 + chara:skill_level("elona.stat_constitution") * 5 < Rand.rnd(quality) then
      Gui.mes_c("smithing.blacksmith_hammer.create.failed", "Red")

      local exp
      if hammer.bonus > 0 then
         exp = 1 + Rand.rnd(math.max(10 / hammer.params.hammer_level), 1)
      else
         exp = 1 + Rand.rnd(math.max(10 / hammer.params.hammer_level), 1) + math.min(hammer.params.hammer_total_uses, quality / 1000)
      end
      Smithing.gain_hammer_experience(hammer, exp)

      hammer.params.hammer_total_uses = hammer.params.hammer_total_uses + 1
      Skill.gain_skill_exp(chara, "elona.stat_constitution", 10)
      Rand.set_seed()
      return nil
   end

   local filter, item_material = Smithing.random_item_filter_and_material(hammer, material, categories, quality)

   local created = Itemgen.create(nil, nil, filter, chara)
   if not created then
      return
   end

   created.identify_state = Enum.IdentifyState.Full
   ItemMaterial.change_item_material(created, item_material)

   if extend > 0
      and not Effect.is_cursed(hammer:calc("curse_state"))
      and created:calc("quality") >= Enum.Quality.Good
   then
      if Rand.one_in(40 / math.min(extend, 40)) then
         Gui.mes("smithing.blacksmith_hammer.create.masterpiece")
         local enc = Smithing.extendable_enchantment(created)
         if enc then
            created:mod_base_enchantment_power(enc._id, enc.params, enc.total_power * 3 / 2)
         end
         created.is_handmade = true
      elseif Rand.one_in(40 / math.min(extend, 20)) then
         Gui.mes("smithing.blacksmith_hammer.create.superior")
         local enc = Smithing.extendable_enchantment(created)
         if enc then
            created:mod_base_enchantment_power(enc._id, enc.params, enc.total_power / 2)
         end
         created.is_handmade = true
      end
   end

   Rand.set_seed()

   if created:calc("quality") >= Enum.Quality.Great then
      Gui.mes_c("smithing.blacksmith_hammer.create.prompt_name_artifact", "Blue")
      local result, canceled = AliasPrompt:new("weapon"):query()

      if result and not canceled then
         local seed = result.seed
         created.title_seed = seed
      end
   end

   Gui.mes_c("smithing.blacksmith_hammer.create.success", "Green", created:build_name(1))
   Gui.play_sound("base.build1", chara.x, chara.y)

   local hammer_exp
   if hammer.bonus > 0 then
      hammer_exp = math.min(hammer.params.hammer_total_uses, quality / 1000) + 1
   else
      hammer_exp = Rand.rnd(math.clamp(quality - hammer.params.hammer_level ^ 3, 1, 0x7FFFFFFF))
         + math.min(hammer.params.hammer_total_uses, quality / 1000)
   end

   Smithing.gain_hammer_experience(hammer, hammer_exp)
   hammer.params.hammer_total_uses = hammer.params.hammer_total_uses + 1
   Skill.gain_skill_exp(chara, "elona.stat_constitution", 50)

   return created
   -- <<<<<<<< oomSEST/src/southtyris.hsp:98697 		} ..
end

function Smithing.repair_furniture(hammer, chara, target_item, material)
   -- >>>>>>>> oomSEST/src/hammer.hsp:722 		ci = craftref(0) ..
   Gui.mes_c("smithing.blacksmith_hammer.repair_furniture.finished", "Green", target_item)
   Gui.play_sound("base.build1", chara.x, chara.y)

   -- TODO this is probably an omake added feature
   --[[
      target_item.params.chara_id = material.params.chara_id
      if target_item.params.chara_id == "elona.user" then
      -- TODO
      end
      if material.is_precious then
      target_item.params_chara_id = 999
      end
   --]]

   local item_material
   if material._id == "elona.remains_skin" then
      item_material = Smithing.material_for_chara(material.params.chara_id)
   elseif material._id == "elona.remains_bone" then
      item_material = "elona.bone"
   elseif material._id == "elona.remains_corpse" then
      item_material = "elona.fresh"
   end
   ItemMaterial.change_item_material(target_item, item_material)

   -- TODO
   -- ibitmod 21, ci, 1

   material:remove(1)

   local exp_gain = 1 + Rand.rnd(10) + math.min(material:calc("value") / 200, 100)
   Smithing.gain_hammer_experience(hammer, exp_gain)
   Skill.gain_skill_exp(chara, "elona.stat_constitution", 50)
   chara:refresh()
   -- <<<<<<<< oomSEST/src/hammer.hsp:766 		gosub *chara_refresh ..
end

function Smithing.upgrade_hammer(hammer, chara)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:98787             ci = craftref(0) ..
   Gui.mes_c("smithing.blacksmith_hammer.upgrade_hammer.finished", "Green", hammer)
   Gui.play_sound("base.build1", chara.x, chara.y)
   hammer.bonus = hammer.bonus + 1
   hammer.params.hammer_level = 1
   hammer.params.hammer_experience = 0
   hammer.params.hammer_total_uses = 0
   Skill.gain_skill_exp(chara, "elona.stat_constitution", 500)
   chara:refresh()
   -- <<<<<<<< oomSEST/src/southtyris.hsp:98798         gosub *chara_refresh ..
end

function Smithing.repair_equipment(hammer, chara, item, power)
   if item.bonus < 0 then
      Gui.mes_c("smithing.blacksmith_hammer.repair_equipment.finished.repair", "Green", item)
   else
      Gui.mes_c("smithing.blacksmith_hammer.repair_equipment.finished.upgrade", "Green", item)
   end
   Gui.play_sound("base.build1", chara.x, chara.y)
   if item.bonus > 0 then
      item.bonus = math.min(item.bonus + item.bonus + 1, power)
   else
      item.bonus = item.bonus + 1
   end

   local exp_gain = 1 + Rand.rnd(math.max(10 / hammer.params.hammer_level, 1))
   Smithing.gain_hammer_experience(hammer, exp_gain)
   Skill.gain_skill_exp(chara, "elona.stat_constitution", 50)
   chara:refresh()
end

return Smithing
