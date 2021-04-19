local Gui = require("api.Gui")
local Input = require("api.Input")
local Item = require("api.Item")
local Skill = require("mod.elona_sys.api.Skill")
local ElonaItem = require("mod.elona.api.ElonaItem")
local Enum = require("api.Enum")
local Rand = require("api.Rand")
local Calc = require("mod.elona.api.Calc")
local Effect = require("mod.elona.api.Effect")
local Itemgen = require("mod.elona.api.Itemgen")
local ItemMaterial = require("mod.elona.api.ItemMaterial")
local AliasPrompt = require("api.gui.AliasPrompt")
local I18N = require("api.I18N")
local IItemEnchantments = require("api.item.IItemEnchantments")
local Env = require("api.Env")
local global = require("mod.smithing.internal.global")
local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")
local IItemBlacksmithHammer = require("mod.smithing.api.aspect.IItemBlacksmithHammer")
local SmithingFormula = require("mod.smithing.api.SmithingFormula")

local Smithing = {}

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
   elseif ElonaItem.is_equipment(item) then
      return true
   elseif item._id == "elona.remains_skin" then
      return true
   elseif item._id == "smithing.blacksmith_hammer" then
      if hammer:get_aspect(IItemBlacksmithHammer):can_upgrade(hammer) and hammer.uid == item.uid then
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
   elseif item._id == "elona.remains_skin" then
      local chara_data = item:get_aspect(IItemFromChara):chara_data(item)
      if chara_data and table.set(chara_data.tags or {})["dragon"] then
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
      local chara_data = item:get_aspect(IItemFromChara):chara_data(item)
      if chara_data or item.is_precious then
         return true
      end
   end

   return false
   -- <<<<<<<< oomSEST/src/hammer.hsp:896 		} ..
end

function Smithing.on_use_blacksmith_hammer(hammer, chara)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:83523 		cw = ci ..
   hammer = hammer:separate()
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
      if not item:get_aspect(IItemBlacksmithHammer):can_upgrade(item) then
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

         local aspect = hammer:get_aspect(IItemBlacksmithHammer)
         power = aspect:calc_equipment_upgrade_power(hammer, item)
         local hammer_level = aspect:calc(hammer, "hammer_level")

         if not (hammer_level >= 21 and item.bonus < power) then
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
   local aspect = hammer:get_aspect(IItemBlacksmithHammer)
   local hammer_level = aspect:calc(hammer, "hammer_level")

   if material._id == "elona.vanilla_rock" then
      item_material = "elona.adamantium"
      local quality_base = math.clamp(hammer_level * 2 / 25, Enum.Quality.Normal, Enum.Quality.Great)
      item_quality = Calc.calc_object_quality(quality_base, map)
   elseif material:has_category("elona.ore_valuable") then
      item_material = Smithing.material_for_ore(material._id)

      local quality_base = quality / (material.value * (11 ^ 2) / math.max(hammer_level * 2 / 25, 1))

      item_quality = Calc.calc_object_quality(math.clamp(quality_base, Enum.Quality.Normal, Enum.Quality.Great), map)
   elseif material._id == "elona.remains_skin" then
      local chara_id = material:calc_aspect(IItemFromChara, "chara_id")
      item_material = Smithing.material_for_chara(chara_id)

      local quality_base = quality / math.max(material.value * 20 / math.max(hammer_level * 2 / 25, 1))

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
      level = hammer_level,
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

   local aspect = hammer:get_aspect(IItemBlacksmithHammer)
   local seed = aspect:calc_item_generation_seed(hammer)
   Rand.set_seed(seed)

   local hammer_level = aspect:calc(hammer, "hammer_level")

   if hammer_level ^ 3 + chara:skill_level("elona.stat_constitution") * 5 < Rand.rnd(quality) then
      Gui.mes_c("smithing.blacksmith_hammer.create.failed", "Red")

      local exp
      if hammer.bonus > 0 then
         exp = 1 + Rand.rnd(math.max(10 / hammer_level), 1)
      else
         exp = 1 + Rand.rnd(math.max(10 / hammer_level), 1) + math.min(aspect.total_uses, quality / 1000)
      end
      aspect:gain_experience(hammer, exp)

      aspect.total_uses = aspect.total_uses + 1
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
      hammer_exp = math.min(aspect.total_uses, quality / 1000) + 1
   else
      hammer_exp = Rand.rnd(math.clamp(quality - hammer_level ^ 3, 1, 0x7FFFFFFF))
         + math.min(aspect.total_uses, quality / 1000)
   end

   aspect:gain_experience(hammer, hammer_exp)
   aspect.total_uses = aspect.total_uses + 1
   Skill.gain_skill_exp(chara, "elona.stat_constitution", 50)

   local display = config.smithing.display_hammer_level
   if display == "sps" or display == "level_and_sps" then
      local timestamp = Env.get_time()
      if global.previous_sps_time then
         global.sps_intervals:push(timestamp - global.previous_sps_time)
      end
      global.previous_sps_time = timestamp
   end

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
      local chara_id = material:calc_aspect(IItemFromChara, "chara_id")
      item_material = Smithing.material_for_chara(chara_id)
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
   hammer:get_aspect(IItemBlacksmithHammer):gain_experience(hammer, exp_gain)
   Skill.gain_skill_exp(chara, "elona.stat_constitution", 50)
   chara:refresh()
   -- <<<<<<<< oomSEST/src/hammer.hsp:766 		gosub *chara_refresh ..
end

function Smithing.upgrade_hammer(hammer, chara)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:98787             ci = craftref(0) ..
   Gui.mes_c("smithing.blacksmith_hammer.upgrade_hammer.finished", "Green", hammer)
   Gui.play_sound("base.build1", chara.x, chara.y)
   hammer:get_aspect(IItemBlacksmithHammer):upgrade(hammer)
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

   local exp_gain = 1 + Rand.rnd(math.max(10 / hammer:calc_aspect(IItemBlacksmithHammer, "hammer_level"), 1))
   hammer:get_aspect(IItemBlacksmithHammer):gain_experience(hammer, exp_gain)
   Skill.gain_skill_exp(chara, "elona.stat_constitution", 50)
   chara:refresh()
end

return Smithing
