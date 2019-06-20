local field = require("game.field")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local ICharaLocation = require("api.chara.ICharaLocation")
local IMapObject = require("api.IMapObject")
local Inventory = require("api.Inventory")

-- TODO: move out of api
local IChara = interface("IChara", {}, {IMapObject, ICharaLocation})

function IChara:build()
   self.hp = self.max_hp
   self.mp = self.max_mp
   self.batch_ind = 0
   self.tile = self.image
   self.state = "Alive"
   self.time_this_turn = 0
   self.turns_alive = 0
   self.level = 1
   self.experience = 0

   self.initial_x = 0
   self.initial_y = 0

   self.fov = 15

   self.inv = Inventory:new(200)
end

function IChara:refresh()
   self.calc = {}
end

function IChara:set_pos(x, y)
   if Chara.at(x, y) ~= nil then
      return false
   end

   return IMapObject.set_pos(self, x, y)
end

function IChara:is_player()
   return field.player.uid == self.uid
end

function IChara:is_ally()
   return table.find_index_of(field.allies, self.uid) ~= nil
end

function IChara:is_in_party()
   return self:is_player() or self:is_ally()
end

function IChara:get_party()
   return nil
end

function IChara:recruit_as_ally()
   if self:is_ally() then
      return false
   end
   field.allies[#field.allies+1] = self.uid
   self.relation = "friendly"
   self.original_relation = "friendly"
   Gui.mes(self.uid .. " joins as an ally! ", "Orange")
   return true
end

function IChara:swap_places(other)
   local map = self.map
   if not map or map ~= other.map then
      return false
   end

   local sx, sy = self.x, self.y
   local ox, oy = other.x, other.y
   map:move_object(self, ox, oy)
   map:move_object(other, sx, sy)

   return true
end

function IChara:damage_hp(amount, source, params)
   return false
end

function IChara:heal_hp(add)
   self.hp = math.min(self.hp + math.max(add, 0), self.max_hp)
end

function IChara:heal_mp(add)
   self.mp = math.min(self.mp + math.max(add, 0), self.max_mp)
end

function IChara:heal_to_max()
   self.hp = self.max_hp
   self.mp = self.max_mp
end

function IChara:kill()
   -- Persist based on character type.
   self.state = "Dead"
end

return IChara
