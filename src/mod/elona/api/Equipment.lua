local Item = require("api.Item")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local Itemgen = require("mod.tools.api.Itemgen")
local elona_Item = require("mod.elona.api.Item")
local Const = require("api.Const")

local Equipment = {}

--- Equips the items in the character's inventory with the highest value.
--- Ignores curse state, intended to be used by the AI.
---
--- @hsp gosub *chara_equipFull@
function Equipment.equip_all_optimally(chara)
   -- >>>>>>>> shade2/adv.hsp:167 *chara_equipFull ..
   local pred = function(i) return Item.is_alive(i) and not i:is_equipped() end
   chara:iter_inventory():each(function(i) Equipment.equip_optimally(chara, i) end)
   -- <<<<<<<< shade2/adv.hsp:173 	return ..
end

function Equipment.equip_optimally(chara, item)
   -- >>>>>>>> shade2/adv.hsp:176 *chara_equip ...
   if item.equip_slots == nil then
      return
   end

   for _, body_part in ipairs(item.equip_slots) do
      local slot = chara:find_equip_slot_for(item, body_part)
      if slot then
         assert(chara:equip_item(item))
         break
      end
      for _, other in chara:iter_items_equipped_at(body_part) do
         if item:calc("value") > other:calc("value") then
            assert(chara:unequip_item(other))
            assert(chara:equip_item(item))
            break
         end
      end
   end
   -- <<<<<<<< shade2/adv.hsp:199 	return ..
end

function Equipment.generate_and_equip(chara)
   -- >>>>>>>> shade2/adv.hsp:201 *supplyEquip ...
   local have_weapon = false
   for i = 1, 100 do
      for _ = 1, 4 do
         local item = Rand.choice(chara:iter_inventory():filter(function(item) return not item:calc("always_drop") end))
         if item then
            item:remove_ownership()
            break
         end
      end

      local filter = { level = chara:calc("level") }
      if chara:find_role("elona.adventurer") then
         filter.quality = Enum.Quality.Good
      else
         filter.quality = Calc.calc_object_quality(Enum.Quality.Normal)
      end

      local category

      for _, slot in chara:iter_all_body_parts() do
         local id = slot.body_part._id
         if slot.equipped then
            if id == "elona.hand" and not have_weapon and slot.equipped:has_category("elona.equip_melee") then
               have_weapon = true
            end
         else
            if id == "elona.hand" and not have_weapon then
               category = "elona.equip_melee"
               break
            elseif id == "elona.head" then
               category = "elona.equip_head"
               break
            elseif id == "elona.body" then
               category = "elona.equip_body"
               break
            elseif id == "elona.ranged" then
               category = "elona.equip_ranged"
               break
            elseif id == "elona.ammo" then
               category = "elona.equip_ammo"
               break
            end
         end
      end

      if not category then
         break
      end

      filter.categories = category
      local item = Itemgen.create(nil, nil, filter, chara)
      item.identify_state = Enum.IdentifyState.Full

      if item.quality >= Enum.Quality.Great
         and elona_Item.is_equipment(item)
         and chara:find_role("elona.adventurer")
      then
         -- TODO adventurer
      end

      Equipment.equip_optimally(chara, item)

      if not chara:find_role("elona.adventurer") and not Rand.one_in(3) then
         break
      end
   end
   -- <<<<<<<< shade2/adv.hsp:247 	return ..
end

function Equipment.generate_random_equipment_spec(chara)
   local quality = chara:calc("quality")

   local gen_chance, add_quality
   if quality <= Enum.Quality.Normal then
      gen_chance = 3
      add_quality = 0
   elseif quality == Enum.Quality.Good then
      gen_chance = 6
      add_quality = 0
   elseif quality == Enum.Quality.Great then
      gen_chance = 8
      add_quality = 1
   else
      gen_chance = 10
      add_quality = 1
   end

   local equip_spec
   if chara.proto.initial_equipment then
      equip_spec = table.deepcopy(chara.proto.initial_equipment)
   else
      equip_spec = {}
   end

   local equipment_type = chara:calc("equipment_type")
   if equipment_type then
      local proto = data["base.equipment_type"]:ensure(equipment_type)
      equip_spec = proto.on_initialize_equipment(chara, equip_spec, gen_chance, add_quality) or equip_spec
   end

   -- >>>>>>>> shade2/chara.hsp:162 	if cQuality(rc)>=fixGreat{ ...
   if quality >= Enum.Quality.Great then
      local i = 0
      while i < 2 do
         if Rand.one_in(2) then
            local spec = Rand.choice(equip_spec)
            if spec then
               spec.quality = Enum.Quality.Good
            end
         end
         if Rand.one_in(2) then
            i = i + 1
         end
      end
   end
   -- <<<<<<<< shade2/chara.hsp:167 		} ..

   chara:emit("elona.on_chara_initialize_equipment", {}, equip_spec)

   return equip_spec, gen_chance, add_quality
end

local spec_kinds = {}

local function default_spec_gen(spec, add_quality, chara, map)
   -- >>>>>>>> shade2/chara.hsp:184 	if p=bodyNeck{ ...
   if spec.category then
      local filter = {
         level = Calc.calc_object_level(chara:calc("level"), map),
         quality = Calc.calc_object_quality(add_quality + spec.quality),
         categories = spec.category,
      }
      return Itemgen.create(nil, nil, filter, chara)
   else
      return Item.create(spec._id, nil, nil, {}, chara)
   end
   -- <<<<<<<< shade2/chara.hsp:196 		} ..
end

spec_kinds["elona.amulet"] = { body_part_type = "elona.neck", generate = default_spec_gen }
spec_kinds["elona.ring"] = { body_part_type = "elona.ring", generate = default_spec_gen }
spec_kinds["elona.cloak"] = { body_part_type = "elona.back", generate = default_spec_gen }
spec_kinds["elona.girdle"] = { body_part_type = "elona.waist", generate = default_spec_gen }
spec_kinds["elona.helmet"] = { body_part_type = "elona.head", generate = default_spec_gen }
spec_kinds["elona.armor"] = { body_part_type = "elona.body", generate = default_spec_gen }
spec_kinds["elona.gloves"] = { body_part_type = "elona.arm", generate = default_spec_gen }
spec_kinds["elona.boots"] = { body_part_type = "elona.leg", generate = default_spec_gen }

spec_kinds["elona.primary_weapon"] = {
   body_part_type = "elona.hand",
   generate = function(spec, add_quality, chara, map)
      -- >>>>>>>> shade2/chara.hsp:271 		if eqWeapon1{ ...
      for i = 1, 15 do
         local item = default_spec_gen(spec, add_quality, chara, map)
         if item and spec.category then
            if spec.is_two_handed and item:calc("weight") < Const.WEAPON_WEIGHT_HEAVY and i < 15 then
               item:remove_ownership()
            elseif spec.is_dual_wield and item:calc("weight") > Const.WEAPON_WEIGHT_LIGHT and i < 15 then
               item:remove_ownership()
            else
               return item
            end
         end
      end

      return nil
      -- <<<<<<<< shade2/chara.hsp:284 			eqWeapon1=false:continue} ..
   end
}

spec_kinds["elona.secondary_weapon"] = {
   body_part_type = "elona.hand",
   generate = function(spec, add_quality, chara, map)
      -- >>>>>>>> shade2/chara.hsp:286 		if eqWeapon2{ ...
      for i = 1, 15 do
         local item = default_spec_gen(spec, add_quality, chara, map)
         if item and spec.category then
            if spec.is_dual_wield and item:calc("weight") > Const.WEAPON_WEIGHT_LIGHT and i < 15 then
               item:remove_ownership()
            else
               return item
            end
         end
      end

      return nil
      -- <<<<<<<< shade2/chara.hsp:298 			continue} ..
   end
}

spec_kinds["elona.multi_weapon"] = {
   body_part_type = "elona.hand",
   generate = function(spec, add_quality, chara, map)
      -- >>>>>>>> shade2/chara.hsp:271 		if eqWeapon1{ ...
      for i = 1, 15 do
         local item = default_spec_gen(spec, add_quality, chara, map)
         if item and spec.category then
            if item:calc("weight") > Const.WEAPON_WEIGHT_LIGHT and i < 15 then
               item:remove_ownership()
            else
               -- generate this item on all available equipment slots. (for
               -- asuras with 4 melee slots to fill)
               return item, "no_remove"
            end
         end
      end

      return nil
      -- <<<<<<<< shade2/chara.hsp:284 			eqWeapon1=false:continue} ..
   end
}

spec_kinds["elona.shield"] = {
   body_part_type = "elona.hand",
   generate = function(spec, add_quality, chara, map)
      -- >>>>>>>> shade2/chara.hsp:171 	if eqTwoHand : eqShield=false ...
      for _, item in chara:iter_items_equipped_at("elona.hand") do
         if item:calc("weight") > Const.WEAPON_WEIGHT_HEAVY then
            return nil
         end
      end
      return default_spec_gen(spec, add_quality, chara, map)
      -- <<<<<<<< shade2/chara.hsp:171 	if eqTwoHand : eqShield=false ..
   end
}
spec_kinds["elona.ranged_weapon"] = { body_part_type = "elona.ranged", generate = default_spec_gen }
spec_kinds["elona.ammo"] = { body_part_type = "elona.ammo", generate = default_spec_gen }

function Equipment.apply_equipment_spec(chara, equip_spec, gen_chance, add_quality, map)
   map = map or chara:current_map()
   for _, entry in chara:iter_all_body_parts() do
      if not entry.equipped then
         for i, spec in ipairs(equip_spec) do
            local spec_kind = assert(spec_kinds[spec.kind], spec.kind)
            if spec_kind.body_part_type == entry.body_part._id then
               local item, no_remove = spec_kind.generate(spec, add_quality, chara, map)
               if item then
                  assert(chara:equip_item(item, true, entry.slot))
                  if not no_remove then
                     equip_spec[i] = equip_spec[#equip_spec]
                     equip_spec[#equip_spec] = nil
                     break
                  end
               end
            end
         end
      end
   end
end

function Equipment.generate_initial_equipment(chara)
   local equip_spec, gen_chance, add_quality = Equipment.generate_random_equipment_spec(chara)
   Equipment.apply_equipment_spec(chara, equip_spec, gen_chance, add_quality)
end

return Equipment
