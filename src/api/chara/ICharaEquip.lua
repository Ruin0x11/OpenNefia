local Event = require("api.Event")
local EquipSlots = require("api.EquipSlots")
local ICharaInventory = require("api.chara.ICharaInventory")
local data = require("internal.data")

local ICharaEquip = class.interface("ICharaEquip", {}, ICharaInventory)

function ICharaEquip:init()
   self.body_parts = self.body_parts or {}
   -- TODO resolver
   self.equip = EquipSlots:new(self.body_parts, self)
   self.equipment_weight = 0
end

local function apply_item_enchantments(chara, item)
   -- >>>>>>>> shade2/calculation.hsp:448 	repeat maxItemEnc ..
   for _, enc in item:iter_enchantments() do
      local enc_data = data["base.enchantment"]:ensure(enc._id)
      if enc_data.on_refresh then
         enc_data.on_refresh(enc, item, chara)
      end
   end
   -- <<<<<<<< shade2/calculation.hsp:492 	loop ..
end

local function apply_item_stats(chara, item)
   -- >>>>>>>> shade2/calculation.hsp:434 	cEqWeight(r1)+=iWeight(rp) ..
   chara:mod("equipment_weight", item:calc("weight"), "add")
   chara:mod("dv", item:calc("dv"), "add")
   chara:mod("pv", item:calc("pv"), "add")
   chara:mod("hit_bonus", item:calc("hit_bonus"), "add")
   chara:mod("damage_bonus", item:calc("damage_bonus"), "add")

   if item:calc("is_melee_weapon") then
      chara:mod("number_of_weapons", 1, "add")
   elseif item:calc("is_armor") then
      local bonus = 0
      if item:is_blessed() then
         bonus = 2
      end
      chara:mod("pv", item:calc("bonus") * 2 + bonus, "add")
   end

   local curse_state = item:calc("curse_state")
   if curse_state == "cursed" then
      chara:mod("curse_power", 20, "add")
   elseif curse_state == "cursed" then
      chara:mod("curse_power", 100, "add")
   end

   local is_ether = item:calc("material") == "elona.ether"
   if is_ether then
      chara:mod("ether_disease_speed", 5, "add")
   end
   -- <<<<<<<< shade2/calculation.hsp:446 	if iMaterial(rp)=mtEther : if r1=pc : gEtherSpeed ...

   apply_item_enchantments(chara, item)

   Event.trigger("base.on_calc_chara_equipment_stats", {chara=chara,item=item})
end

function ICharaEquip:iter_enchantments()
   local iters = self:iter_equipment():map(
      function(i)
         local enc_iter = i:iter_enchantments();
         -- (i, enc) -> (i, enc, item_with_enc)
         local item_dup = fun.duplicate(i)
         return fun.zip(enc_iter, item_dup)
      end):to_list()
   return fun.chain(table.unpack(iters))
end

function ICharaEquip:find_enchantment(_id)
   data["base.enchantment"]:ensure(_id)
   return self:iter_enchantments():filter(function(enc) return enc._id == _id end):nth(1)
end

function ICharaEquip:on_refresh()
   local attack_count = 0
   for _, part in self:iter_body_parts() do
      local item = part.equipped
      if item then
         item:refresh()

         apply_item_stats(self, item)

         if part.body_part._id == "elona.hand" then
            attack_count = attack_count + 1
         end
         if item:has_category("elona.equip_shield") then
            self:mod("is_wielding_shield", true)
         end
      end
   end

   -- >>>>>>>> shade2/calculation.hsp:530 	if cAttackStyle(r1)&styleShield{ ..
   if self:calc("is_wielding_shield") then
      local pv = self:calc("pv")
      if pv > 0 then
         self:mod("pv", pv * math.floor( 120 + math.sqrt(self:skill_level("elona.shield")) * 2 ) / 100)
      end
   else
      if attack_count == 1 then
         self:mod("is_wielding_two_handed", true)
      elseif attack_count > 0 then
         self:mod("is_dual_wielding", true)
      end
   end
   -- <<<<<<<< shade2/calculation.hsp:534 		} ..
end

function ICharaEquip:equip_item(item, force)
   if not self:has_item(item) then
      if force then
         if not self:take_item(item) then
            return nil, "cannot_take"
         end
      else
         return nil, "not_owned"
      end
   end

   local result, err = self.equip:equip(item)
   item:refresh()

   return result, err
end

function ICharaEquip:has_item_equipped(item)
   return self.equip:has_object(item)
end

function ICharaEquip:items_equipped_at(body_part_type)
   return self.equip:items_equipped_at(body_part_type)
end

function ICharaEquip:find_equip_slot_for(item, body_part_type)
   return self.equip:find_free_slot(item, body_part_type)
end

-- Returns true if the given item is equipped or in the character's
-- inventory.
function ICharaEquip:has_item(item)
   return self:has_item_in_inventory(item) or self:has_item_equipped(item)
end

function ICharaEquip:unequip_item(item)
   if not self.equip:has_object(item) then
      return nil
   end

   local result = self:take_item(item)
   item:refresh()

   return result
end

-- Iterates all body parts on this character, including empty slots.
-- @treturn iterator
function ICharaEquip:iter_body_parts(also_empty)
   return self.equip:iter_body_parts(also_empty)
end

-- Iterates the items that are equipped on this character.
-- @treturn iterator
function ICharaEquip:iter_equipment()
   return self.equip:iter()
end

function ICharaEquip:has_body_part_for(item)
   return self.equip:has_body_part_for(item)
end

-- Adds a new body part to this character.
-- @tparam base.body_part _type
function ICharaEquip:add_body_part(_type)
   self.equip:add_body_part(_type)
end

-- Attempts to remove a body part. If something is equipped there,
-- this function fails unless `force` is true. If `force` is true when
-- an item is equipped there, removes the item, makes it ownerless and
-- returns it. If unsuccessful, no state is changed.
-- @tparam int|string type_or_slot
-- @tparam bool force
-- @treturn[1] nil
-- @treturn[2] IItem
-- @retval_ownership nil
function ICharaEquip:remove_body_part(type_or_slot, force)
   -- TODO
end

-- Marks a slot or body part as "blocked" for use as a refreshed
-- value. It will be hidden in the equipment menu for the character.
function ICharaEquip:temp_block_body_part()
   -- TODO
end

return ICharaEquip
