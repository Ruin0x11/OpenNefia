local Item = require("api.Item")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local Itemgen = require("mod.elona.api.Itemgen")
local ElonaItem = require("mod.elona.api.ElonaItem")
local Const = require("api.Const")
local Stopwatch = require("api.Stopwatch")
local Log = require("api.Log")
local News = require("mod.elona.api.News")
local text = require("thirdparty.pl.text")
local I18N = require("api.I18N")
local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")

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
   local equip = item:get_aspect(IItemEquipment)
   if equip == nil then
      return
   end

   local equip_slots = equip:calc(item, "equip_slots") or {}

   for _, body_part in ipairs(equip_slots) do
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
         and ElonaItem.is_equipment(item)
         and chara:find_role("elona.adventurer")
      then
         -- >>>>>>>> shade2/text.hsp:1319 	if type=1{ ...
         local Adventurer = require("mod.elona.api.Adventurer")
         local staying_area = Adventurer.area_of(chara)
         if staying_area then
            local topic = I18N.get("news.discovery.title")
            local text = I18N.get("news.discovery.text", chara.title, chara.name, item:build_name(1), staying_area.name)

            -- >>>>>>>> shade2/adv.hsp:239 		if cRole(rc)=cRoleAdv : valn=itemname(ci):addNew ...
            News.add(text, topic)
            -- <<<<<<<< shade2/adv.hsp:239 		if cRole(rc)=cRoleAdv : valn=itemname(ci):addNew ..
         end
         -- <<<<<<<< shade2/text.hsp:1322 		} ...
      end

      Equipment.equip_optimally(chara, item)

      if not chara:find_role("elona.adventurer") and not Rand.one_in(3) then
         break
      end
   end
   -- <<<<<<<< shade2/adv.hsp:247 	return ..
end

function Equipment.generate_initial_equipment_spec(chara)
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

   local equip_spec = {}

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

local function default_spec_gen(spec, equip_spec, add_quality, chara, map)
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

spec_kinds["elona.amulet_1"] = default_spec_gen
spec_kinds["elona.amulet_2"] = default_spec_gen
spec_kinds["elona.ring_1"] = default_spec_gen
spec_kinds["elona.ring_2"] = default_spec_gen
spec_kinds["elona.cloak"] = default_spec_gen
spec_kinds["elona.girdle"] = default_spec_gen
spec_kinds["elona.helmet"] = default_spec_gen
spec_kinds["elona.armor"] = default_spec_gen
spec_kinds["elona.gloves"] = default_spec_gen
spec_kinds["elona.boots"] = default_spec_gen

local MAX_TRIES = 15

spec_kinds["elona.primary_weapon"] = function(spec, equip_spec, add_quality, chara, map)
   -- >>>>>>>> shade2/chara.hsp:171 	if eqTwoHand : eqShield=false ...
   if spec.is_two_handed then
      equip_spec["elona.shield"] = nil
   end
   -- <<<<<<<< shade2/chara.hsp:171 	if eqTwoHand : eqShield=false ..

   -- >>>>>>>> shade2/chara.hsp:271 		if eqWeapon1{ ...
   for i = 1, MAX_TRIES do
      local item = default_spec_gen(spec, equip_spec, add_quality, chara, map)
      if item then
         if spec.is_two_handed and item.weight < Const.WEAPON_WEIGHT_HEAVY and i < MAX_TRIES then
            item:remove_ownership()
         elseif spec.is_dual_wield and item.weight > Const.WEAPON_WEIGHT_LIGHT and i < MAX_TRIES then
            item:remove_ownership()
         else
            return item
         end
      end
   end

   return nil
   -- <<<<<<<< shade2/chara.hsp:284 			eqWeapon1=false:continue} ..
end

spec_kinds["elona.secondary_weapon"] = function(spec, equip_spec, add_quality, chara, map)
   -- >>>>>>>> shade2/chara.hsp:286 		if eqWeapon2{ ...
   for i = 1, MAX_TRIES do
      local item = default_spec_gen(spec, equip_spec, add_quality, chara, map)
      if item then
         if spec.is_dual_wield and item.weight > Const.WEAPON_WEIGHT_LIGHT and i < MAX_TRIES then
            item:remove_ownership()
         else
            return item
         end
      end
   end

   return nil
   -- <<<<<<<< shade2/chara.hsp:298 			continue} ..
end

spec_kinds["elona.multi_weapon"] = function(spec, equip_spec, add_quality, chara, map)
   -- >>>>>>>> shade2/chara.hsp:271 		if eqWeapon1{ ...
   equip_spec["elona.primary_weapon"] = nil

   for i = 1, MAX_TRIES do
      local item = default_spec_gen(spec, equip_spec, add_quality, chara, map)
      if item then
         if item.weight > Const.WEAPON_WEIGHT_LIGHT and i < MAX_TRIES then
            item:remove_ownership()
         else
            -- generate this item on all available equipment slots. (used by
            -- asuras with 4 melee slots to fill)
            return item, "no_remove"
         end
      end
   end
   -- <<<<<<<< shade2/chara.hsp:284 			eqWeapon1=false:continue} ..
end

spec_kinds["elona.shield"] = default_spec_gen
spec_kinds["elona.ranged_weapon"] = default_spec_gen
spec_kinds["elona.ammo"] = default_spec_gen

local body_to_specs = {}
body_to_specs["elona.neck"] = { "elona.amulet" }
body_to_specs["elona.ring"] = { "elona.ring" }
body_to_specs["elona.back"] = { "elona.cloak" }
body_to_specs["elona.waist"] = { "elona.girdle" }
body_to_specs["elona.head"] = { "elona.helmet" }
body_to_specs["elona.body"] = { "elona.armor" }
body_to_specs["elona.arm"] = { "elona.gloves" }
body_to_specs["elona.leg"] = { "elona.boots" }
body_to_specs["elona.hand"] = {
   "elona.multi_weapon",
   "elona.primary_weapon",
   "elona.secondary_weapon",
   "elona.shield"
}
body_to_specs["elona.ranged"] = {
   "elona.ranged_weapon"
}
body_to_specs["elona.ammo"] = {
   "elona.ammo"
}

function Equipment.apply_equipment_spec(chara, equip_spec, gen_chance, add_quality, map)
   map = map or chara:current_map()
   local sw = Stopwatch:new("warn")
   for _, entry in chara:iter_all_body_parts() do
      if not entry.equipped then
         -- Let's see if there's a way to randomly generate equipment for this
         -- body part type. This should always be true for the vanilla body
         -- parts.
         local specs_for_part = body_to_specs[entry.body_part._id]
         if specs_for_part == nil then
            Log.error("Missing equipment generator entries for %s", entry.body_part._id)
            specs_for_part = {}
         end

         for _, spec_id in ipairs(specs_for_part) do
            -- Now let's see if the character has something to generate for this
            -- spec kind.
            local spec = equip_spec[spec_id]
            if spec then
               -- Grab the generator for this spec kind and run it. For example,
               -- a `spec_id` of "elona.multi_weapon" will generate enough
               -- weapons to fill all the character's hand slots, while
               -- "elona.primary_weapon" stops generating after the first hand
               -- slot was found.
               local generator = assert(spec_kinds[spec_id])
               local item, no_remove = generator(spec, equip_spec, add_quality, chara, map)
               if not no_remove then
                  -- Don't generate for this spec kind again, to prevent e.g.
                  -- two primary weapons from being created.
                  equip_spec[spec_id] = nil
               end
               if item then
                  -- The item ought to be compatible with this body part, or
                  -- we're being weird.
                  if not chara:equip_item(item, true, entry.slot) then
                     Log.error("Could not equip generated equipment for body part %s on %s", entry.body_part._id, chara._id)
                     item:remove_ownership()
                  end
                  break
               end
            end
         end
      end
   end
end

function Equipment.generate_initial_equipment(chara)
   local equip_spec, gen_chance, add_quality = Equipment.generate_initial_equipment_spec(chara)
   Equipment.apply_equipment_spec(chara, equip_spec, gen_chance, add_quality)
end

return Equipment
