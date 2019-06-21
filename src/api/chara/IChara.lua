local field = require("game.field")
local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Map = require("api.Map")
local ICharaLocation = require("api.chara.ICharaLocation")
local ICharaFaction = require("api.chara.ICharaFaction")
local ICharaTalk = require("api.chara.ICharaTalk")
local IMapObject = require("api.IMapObject")
local IObserver = require("api.IObserver")
local Inventory = require("api.Inventory")
local InstancedMap = require("api.InstancedMap")

-- TODO: move out of api
local IChara = interface("IChara",
                         {},
                         {
                            IMapObject,
                            ICharaLocation,
                            ICharaFaction,
                            ICharaTalk,
                            IObserver
                         })

function IChara:build()
   IMapObject.init(self)

   self.hp = self.max_hp
   self.mp = self.max_mp
   self.batch_ind = 0
   self.tile = self.image
   self.state = "Alive"
   self.time_this_turn = 0
   self.turns_alive = 0
   self.level = 1
   self.experience = 0
   self.quality = 2

   self.initial_x = 0
   self.initial_y = 0

   self.fov = 15

   self.inv = Inventory:new(200)

   self.personal_reactions = {}

   self.target = nil

   self.ai = "base.elona_default_ai"
   self.ai_state = {
      hate = 0,
      player_attacker = nil,
      item_to_be_used = nil,
      wants_movement = 0,
      last_target_x = 0,
      last_target_y = 0,
      anchor_x = nil,
      anchor_y = nil,
      is_anchored = false,
   }

   -- TODO schema
   self.ai_config = self.ai_config or
      {
         min_distance = 1,
         move_chance_percent = 100,
         sub_act_chance_percent = 10,
         follow_player_when_calm = false,

         on_low_hp = nil,
         on_idle_action = nil
      }

   self.known_abilities = self.known_abilities or {}

   IObserver.init(self)
   ICharaTalk.init(self)
end

function IChara:refresh()
   self.temp = {}
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

   self.faction = "base.friendly"
   self:refresh()

   Gui.mes(self.uid .. " joins as an ally! ", "Orange")
   return true
end

function IChara:swap_places(other)
   local location = self.location
   if not location or location ~= other.location then
      return false
   end

   local sx, sy = self.x, self.y
   local ox, oy = other.x, other.y
   location:move_object(self, ox, oy)
   location:move_object(other, sx, sy)

   return true
end

local function calc_kill_exp(attacker, victim)
   local gained_exp = math.clamp(victim.level, 1, 200)
      * math.clamp(victim.level + 1, 1, 200)
      * math.clamp(victim.level + 2, 1, 100)
      / 20 + 8;
   if victim.level > attacker.level then
      gained_exp = gained_exp / 4
   end

   local result = Event.trigger("base.on_calc_kill_exp", {attacker=attacker,victim=victim,gained_exp=gained_exp})
   if result.gained_exp then
      gained_exp = gained_exp
   end

   return gained_exp
end

function IChara:damage_hp(amount, source, params)
   params = params or {}

   local victim = self

   local event_params = {
      chara = victim,
      amount = amount,
      source = source,
      params = params
   }

   local attacker = nil
   if type(source) == "table" and source._type == "base.chara" then
      attacker = source
   end

   if not Chara.is_alive(victim) then
      Event.trigger("base.after_damage_hp", event_params)
      return true
   end

   local damage = amount
   event_params.damage = damage

   local result = Event.trigger("base.on_calc_damage", event_params)
   if type(result.damage) == "number" then
      damage = result.damage
   end

   victim.hp = math.min(victim.hp - damage, victim.max_hp)

   Event.trigger("base.after_chara_damaged", event_params)

   local damage_level
   if damage <= 0 then
      damage_level = -1
   else
      damage_level = math.floor(damage * 6 / victim.max_hp)
   end

   if victim.hp >= 0 then
      if params.element and params.damage_text_type == "element" then
         show_element_text_damage(victim, source, victim, params.element)
      elseif params.damage_text_type == "damage" then
         Gui.mes_continue_sentence()
         if damage_level == -1 then
            Gui.mes(victim.uid .. " is scratched.")
         elseif damage_level == 0 then
            Gui.mes(victim.uid .. " is slightly wounded.", "Orange")
         elseif damage_level == 1 then
            Gui.mes(victim.uid .. " is moderately wounded.", "Gold")
         elseif damage_level == 2 then
            Gui.mes(victim.uid .. " is severely wounded.", "LightRed")
         elseif damage_level >= 3 then
            Gui.mes(victim.uid .. " is critically wounded.", "Red")
         end
      end

      if Map.is_in_fov(victim.x, victim.y) then
         if damage_level == 1 then
            Gui.mes(victim.uid .. " screams.")
         elseif damage_level == 2 then
            Gui.mes(victim.uid .. " writhes in pain.")
         elseif damage_level >= 3 then
            Gui.mes(victim.uid .. " is severely hurt.")
         end
         if damage < 0 then
            Gui.mes(victim.uid .. " is healed.")
         end
      end

      attacker:act_hostile_towards(victim)

      if attacker and not Chara.is_player(victim) then
         local apply_hate
         if victim:reaction_towards(attacker) < 0 or attacker:reaction_towards(victim, "original") < 0 then
            if victim.ai_state.hate == 0 and Rand.one_in(4) then
               apply_hate = true
            end
         end
         if not attacker:is_player() and attacker:get_target() == victim and Rand.one_in(3) then
            apply_hate = true
         end

         if apply_hate then
            if victim:get_hate_at(attacker) == 0 then
               victim.ai_state.hate = 20
               victim:set_target(attacker)
            else
               victim.ai_state.hate = victim.ai_state.hate + 2
            end
         end
      end
   end

   local killed = false
   if victim.hp < 0 then
      killed = true

      victim:kill(source)

      if attacker then
         local gained_exp = calc_kill_exp(attacker, victim)

         attacker.experience = attacker.experience + gained_exp
         -- TODO sleep exp
         if attacker:is_in_party() then
            attacker:set_target(nil)
            Chara.player():set_target(nil)
         end
      end

      -- on kill quest chara
      -- TODO: block if void/showroom
      if not victim:is_player() then
         if victim.on_death then
            victim.on_death(damage, source)
         end
      end
   end

   Event.trigger("base.after_damage_hp", event_params)

   return killed
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

function IChara:kill(source)
   if not Chara.is_alive(self) then
      return
   end

   if is_an(IChara, source) then
      local death_type = Rand.rnd(4)
      Gui.mes(self.uid .. " was killed.")
   else
      if source and source.get_death_cause then
         local death_cause = source.get_death_cause()
      else
         Gui.mes(self.uid .. " dies.")
      end
   end

   Event.trigger("base.on_chara_killed", {chara=self,source=source})

   self.state = "Dead"
end

function IChara:current_map()
   if is_an(InstancedMap, self.location) then
      return self.location
   end

   return nil
end

function IChara:revive()
   if Chara.is_alive(self) then
      return
   end

   local map = self:current_map()
   if map == nil then
      return false
   end

   local nx, ny = Map.find_position_for_chara(self, self.x, self.y, map)

   if nx == nil then
      return false
   end

   self.state = "Alive"
   self:set_pos(nx, ny)
   self:heal_to_max()

   Gui.mes(self.uid .. " has revived!")

   Event.trigger("base.on_chara_revived", {chara=self})

   return true
end

function IChara:set_target(target)
   self.target = target
end

function IChara:get_target()
   return self.target
end

return IChara
