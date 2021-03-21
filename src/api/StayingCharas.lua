local MapObject = require("api.MapObject")
local ILocation = require("api.ILocation")
local Map = require("api.Map")
local IOwned = require("api.IOwned")
local ObjectContainer = require("api.ObjectContainer")
local Chara = require("api.Chara")
local InstancedMap = require("api.InstancedMap")
local Log = require("api.Log")
local I18N = require("api.I18N")
local InstancedArea = require("api.InstancedArea")
local Area = require("api.Area")
local save = require("internal.global.save")
local ICharaParty = require("api.chara.ICharaParty")

local StayingCharas = class.class("StayingCharas", ILocation)

StayingCharas:delegate("container", ILocation)

function StayingCharas:init(owner)
   if owner then
      assert(class.is_an(IOwned, owner))
      self._parent = owner
   end

   self.container = ObjectContainer:new("base.chara", self)
   self.area_uid_to_chara_uids = {}
   self.chara_uid_to_area_uid = {}
end


local function iter_staying_allies()
   return StayingCharas.iter_global():filter(ICharaParty.is_in_player_party)
end

function StayingCharas.iter_allies_and_stayers(map)
   return fun.chain(Chara.player():iter_other_party_members(map), iter_staying_allies())
end

function StayingCharas.register_global(chara, area, floor)
   save.base.staying_charas:register(chara, area, floor)
end

function StayingCharas.unregister_global(chara, area, floor)
   save.base.staying_charas:unregister(chara, area, floor)
end

function StayingCharas.iter_global()
   return save.base.staying_charas:iter()
end

function StayingCharas.get_staying_area_for_global(chara)
   return save.base.staying_charas:get_staying_area_for(chara)
end

function StayingCharas.is_staying_in_map_global(chara, map)
   return save.base.staying_charas:is_staying_in_map(chara, map)
end

function StayingCharas.is_staying_in_area_global(chara, area, floor)
   return save.base.staying_charas:is_staying_in_map(chara, area, floor)
end

function StayingCharas:register(chara, area, floor)
   assert(MapObject.is_map_object(chara, "base.chara"))
   class.assert_is_an(InstancedArea, area)
   assert(math.type(floor) == "integer", "Floor must be an integer")
   local old_area = self:get_staying_area_for(chara)
   if old_area then
      self.area_uid_to_chara_uids[old_area.area_uid][chara.uid] = nil
      self.chara_uid_to_area_uid[chara.uid] = nil
   end

   local map = chara:current_map()
   if map then
      local ok, meta = area:get_floor(floor)
      if ok and meta and meta.uid == map.uid then
         chara.initial_x = chara.x
         chara.initial_y = chara.y
      else
         chara.initial_x = math.floor(map:width() / 2)
         chara.initial_y = math.floor(map:height() / 2)
      end
   end

   self.area_uid_to_chara_uids[area.uid] = self.area_uid_to_chara_uids[area.uid] or {}
   self.area_uid_to_chara_uids[area.uid][chara.uid] = true
   self.chara_uid_to_area_uid[chara.uid] = {
      area_uid = area.uid,
      area_floor = floor,
      area_name = area.name or I18N.get("ui.adventurers.unknown"),
   }
end

function StayingCharas:unregister(chara, area, floor)
   assert(MapObject.is_map_object(chara, "base.chara"))
   local old_area = self:get_staying_area_for(chara)
   if not old_area then
      return
   end
   if area and old_area.area_uid ~= area.uid then
      return
   end
   if floor and old_area.area_floor ~= floor then
      return
   end

   self.area_uid_to_chara_uids[old_area.area_uid][chara.uid] = nil
   self.chara_uid_to_area_uid[chara.uid] = nil

   return nil
end

function StayingCharas:get_staying_area_for(chara)
   assert(MapObject.is_map_object(chara, "base.chara"))
   local area = self.chara_uid_to_area_uid[chara.uid]
   if not area then
      return nil
   end

   return {
      area_uid = area.area_uid,
      area_name = area.area_name,
      area_floor = area.area_floor
   }
end

function StayingCharas:unregister_for_area(area, floor)
   class.assert_is_an(InstancedArea, area)
   assert(math.type(floor) == "integer")

   self.area_uid_to_chara_uids[area.uid] = nil
   for chara_uid, area_data in pairs(self.chara_uid_to_area_uid) do
      if area_data.area_uid == area.uid and area_data.area_floor == floor then
         self.chara_uid_to_area_uid[chara_uid] = nil
      end
   end
end

function StayingCharas:unregister_all_for_area(area)
   class.assert_is_an(InstancedArea, area)

   self.area_uid_to_chara_uids[area.uid] = nil
   for chara_uid, area_data in pairs(self.chara_uid_to_area_uid) do
      if area_data.area_uid == area.uid then
         self.chara_uid_to_area_uid[chara_uid] = nil
      end
   end
end

function StayingCharas:is_staying_in_area(chara, area, floor)
   assert(MapObject.is_map_object(chara, "base.chara"))
   class.assert_is_an(InstancedArea, area)
   assert(math.type(floor) == "integer")

   local staying_area = self:get_staying_area_for(chara)
   if staying_area == nil then
      return false
   end

   return staying_area.area_uid == area.uid and staying_area.area_floor == floor
end

function StayingCharas:is_staying_in_map(chara, map)
   class.assert_is_an(InstancedMap, map)

   local area, floor = Area.for_map(map)
   if area == nil or floor == nil then
      return false
   end

   return self:is_staying_in_area(chara, area, floor)
end

function StayingCharas:do_transfer(prev_map, map, filter)
   local area, floor = Area.for_map(map)

   local is_outside_staying_area = function(chara)
      local staying_area = self:get_staying_area_for(chara)
      return chara.state == "Alive"
         and not chara:is_player()
         and staying_area
         and (area == nil or staying_area.area_uid ~= area.uid or floor ~= staying_area.area_floor)
   end

   local function take(chara)
      assert(self:take_object(chara))
      assert(chara:get_location() == self)
   end

   -- Check both the previous and next map, since by now the allies of the
   -- player might have been transferred to the next map.
   Chara.iter_all(prev_map):filter(is_outside_staying_area):each(take)
   Chara.iter_all(map):filter(is_outside_staying_area):each(take)

   local is_inside_staying_area = function(chara)
      local staying_area = self:get_staying_area_for(chara)

      if filter then
         return filter(chara, map, area, floor, staying_area)
      else
         if area == nil
            or staying_area == nil
            or area.uid ~= staying_area.area_uid
            or floor ~= staying_area.area_floor
         then
            return false
         end
      end

      return true
   end

   local function place(chara)
      local x = chara.initial_x
      local y = chara.initial_y
      if not Map.try_place_chara(chara, x, y, map) then
         Log.warn("Could not restore staying character %d (%s)", chara.uid, chara.name)
      end
   end

   local charas = self:iter():filter(is_inside_staying_area):to_list()
   for _, chara in ipairs(charas) do
      place(chara)
   end
   return fun.iter(charas)
end

return StayingCharas
