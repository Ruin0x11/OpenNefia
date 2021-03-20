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

local StayingAdventurers = class.class("StayingAdventurers", ILocation)

StayingAdventurers:delegate("container", ILocation)

function StayingAdventurers:init(owner)
   if owner then
      assert(class.is_an(IOwned, owner))
      self._parent = owner
   end

   self.container = ObjectContainer:new("base.chara", self)
   self.area_uid_to_chara_uids = {}
   self.chara_uid_to_area_uid = {}
end

function StayingAdventurers:register(chara, area)
   assert(MapObject.is_map_object(chara, "base.chara"))
   class.assert_is_an(InstancedArea, area)
   local old_area = self:get_staying_area_for(chara)
   if old_area then
      self.area_uid_to_chara_uids[old_area.area_uid][chara.uid] = nil
      self.chara_uid_to_area_uid[chara.uid] = nil
   end

   self.area_uid_to_chara_uids[area.uid] = self.area_uid_to_chara_uids[area.uid] or {}
   self.area_uid_to_chara_uids[area.uid][chara.uid] = true
   self.chara_uid_to_area_uid[chara.uid] = {
      area_uid = area.uid,
      area_name = area.name or I18N.get("ui.adventurers.unknown"),
   }
end

function StayingAdventurers:unregister(chara, area)
   assert(MapObject.is_map_object(chara, "base.chara"))
   local old_area = self:get_staying_area_for(chara)
   if not old_area then
      return
   end
   if area and old_area.area_uid ~= area.uid then
      return
   end

   self.area_uid_to_chara_uids[old_area.area_uid][chara.uid] = nil
   self.chara_uid_to_area_uid[chara.uid] = nil

   return nil
end

function StayingAdventurers:get_staying_area_for(chara)
   assert(MapObject.is_map_object(chara, "base.chara"))
   local area = self.chara_uid_to_area_uid[chara.uid]
   if not area then
      return nil
   end

   return {
      area_uid = area.area_uid,
      area_name = area.area_name
   }
end

function StayingAdventurers:unregister_for_map(uid)
   assert(math.type(uid) == "integer")

   self.area_uid_to_chara_uids[uid] = nil
   for chara_uid, area_data in pairs(self.chara_uid_to_area_uid) do
      if area_data.area_uid == uid then
         self.chara_uid_to_area_uid[chara_uid] = nil
      end
   end
end

function StayingAdventurers:is_staying_in_area(chara, area)
   assert(MapObject.is_map_object(chara, "base.chara"))
   class.assert_is_an(InstancedMap, area)

   local staying_area = self:get_staying_area_for(chara)
   if staying_area == nil then
      return false
   end

   return staying_area.area_uid == area.uid
end

local function should_transfer(chara, map, area, staying_area)
   local role = chara:find_role("elona.adventurer")
   if role == nil then
      return false
   end

   if role.state ~= "Alive" then
      return false
   end

   if chara:calc("is_hired") then
      return true
   end

   if not (map:has_type("town") or map:has_type("guild")) then
      return false
   end

   local floor = Map.floor_number(map)
   if floor ~= 1 then
      return false
   end

   -- TODO arena

   return area and staying_area.area_uid == area.uid
end

function StayingAdventurers:do_transfer(map)
   local area = Area.for_map(map)
   local floor
   if area then
      floor = assert(area:floor_of_map(map.uid))
   end

   local is_outside_staying_area = function(chara)
      local staying_area = self:get_staying_area_for(chara)
      return chara.state == "Alive"
         and not chara:is_player()
         and staying_area
         and (staying_area.area_uid ~= map.uid or floor ~= 1)
   end

   local function take(chara)
      assert(self:take_object(chara))
      assert(chara:get_location() == self)
   end

   Chara.iter_all(map):filter(is_outside_staying_area):each(take)

   local is_inside_staying_area = function(chara)
      local staying_area = self:get_staying_area_for(chara)
      return should_transfer(chara, map, area, staying_area)
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

return StayingAdventurers
