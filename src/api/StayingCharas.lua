local MapObject = require("api.MapObject")
local ILocation = require("api.ILocation")
local Map = require("api.Map")
local IOwned = require("api.IOwned")
local ObjectContainer = require("api.ObjectContainer")
local Chara = require("api.Chara")
local InstancedMap = require("api.InstancedMap")
local Log = require("api.Log")
local save = require("internal.global.save")
local I18N = require("api.I18N")

local StayingCharas = class.class("StayingCharas", ILocation)

StayingCharas:delegate("container", ILocation)

function StayingCharas:init(owner)
   if owner then
      assert(class.is_an(IOwned, owner))
      self._parent = owner
   end

   self.container = ObjectContainer:new("base.chara", self)
   self.map_uid_to_chara_uids = {}
   self.chara_uid_to_map_uid = {}
end

function StayingCharas.register_global(chara, map)
   save.base.staying_charas:register(chara, map)
end

function StayingCharas.unregister_global(chara)
   save.base.staying_charas:unregister(chara)
end

function StayingCharas.iter_global()
   return save.base.staying_charas:iter()
end

function StayingCharas.get_staying_map_for_global(chara)
   return save.base.staying_charas:get_staying_map_for(chara)
end

function StayingCharas.is_staying_in_map_global(chara, map)
   return save.base.staying_charas:is_staying_in_map(chara, map)
end

function StayingCharas:register(chara, map)
   assert(MapObject.is_map_object(chara, "base.chara"))
   class.assert_is_an(InstancedMap, map)
   local old_map = self:get_staying_map_for(chara)
   if old_map then
      self.map_uid_to_chara_uids[old_map.map_uid][chara.uid] = nil
      self.chara_uid_to_map_uid[chara.uid] = nil
   end

   chara.initial_x = chara.x
   chara.initial_y = chara.y

   self.map_uid_to_chara_uids[map.uid] = self.map_uid_to_chara_uids[map.uid] or {}
   self.map_uid_to_chara_uids[map.uid][chara.uid] = true
   self.chara_uid_to_map_uid[chara.uid] = {
      map_uid = map.uid,
      map_name = map.name or I18N.get("ui.adventurers.unknown"),
   }
end

function StayingCharas:unregister(chara)
   assert(MapObject.is_map_object(chara, "base.chara"))
   local old_map = self:get_staying_map_for(chara)
   if not old_map then
      return
   end

   self.map_uid_to_chara_uids[old_map.map_uid][chara.uid] = nil
   self.chara_uid_to_map_uid[chara.uid] = nil

   return nil
end

function StayingCharas:get_staying_map_for(chara)
   assert(MapObject.is_map_object(chara, "base.chara"))
   local map = self.chara_uid_to_map_uid[chara.uid]
   if not map then
      return nil
   end

   return {
      map_uid = map.map_uid,
      map_name = map.map_name,
      start_x = map.start_x,
      start_y = map.start_y
   }
end

function StayingCharas:is_staying_in_map(chara, map)
   assert(MapObject.is_map_object(chara, "base.chara"))
   class.assert_is_an(InstancedMap, map)

   local staying_map = self:get_staying_map_for(chara)
   if staying_map == nil then
      return false
   end

   return staying_map.map_uid == map.uid
end

function StayingCharas:do_transfer(map)
   local is_outside_staying_map = function(chara)
      local staying_map = self:get_staying_map_for(chara)
      return chara.state == "Alive"
         and not chara:is_player()
         and staying_map
         and staying_map.map_uid ~= map.uid
   end

   local function take(chara)
      assert(self:take_object(chara))
      assert(chara:get_location() == self)
      chara.state = "Staying"
   end

   Chara.iter_all(map):filter(is_outside_staying_map):each(take)

   local is_inside_staying_map = function(chara)
      local staying_map = self:get_staying_map_for(chara)
      return staying_map
         and staying_map.map_uid == map.uid
   end

   local function place(chara)
      local x = chara.initial_x
      local y = chara.initial_y
      if Map.try_place_chara(chara, x, y, map) then
         chara.state = "Alive"
      else
         Log.warn("Could not restore staying character %d (%s)", chara.uid, chara.name)
      end
   end

   self:iter():filter(is_inside_staying_map):each(place)
end

return StayingCharas
