local Item = require("api.Item")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local Itemgen = require("mod.tools.api.Itemgen")
local elona_Item = require("mod.elona.api.Item")

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

return Equipment
