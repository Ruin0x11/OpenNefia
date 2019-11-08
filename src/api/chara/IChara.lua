local data = require("internal.data")
local field = require("game.field")
local Chara = require("api.Chara")
local Codegen = require("api.Codegen")
local Rand = require("api.Rand")
local Resolver = require("api.Resolver")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Map = require("api.Map")
local ICharaEffects = require("api.chara.ICharaEffects")
local ICharaEquip = require("api.chara.ICharaEquip")
local ICharaInventory = require("api.chara.ICharaInventory")
local ICharaParty = require("api.chara.ICharaParty")
local ICharaActivity = require("api.chara.ICharaActivity")
local ICharaSkills = require("api.chara.ICharaSkills")
local ICharaTraits = require("api.chara.ICharaTraits")
local IObject = require("api.IObject")
local ICharaTalk = require("api.chara.ICharaTalk")
local IModdable = require("api.IModdable")
local IFactioned = require("api.IFactioned")
local IMapObject = require("api.IMapObject")
local IEventEmitter = require("api.IEventEmitter")
local save = require("internal.global.save")

-- TODO: move out of api
local IChara = class.interface("IChara",
                         {},
                         {
                            IMapObject,
                            IModdable,
                            ICharaInventory,
                            IFactioned,
                            ICharaTalk,
                            ICharaEquip,
                            ICharaParty,
                            ICharaSkills,
                            ICharaTraits,
                            ICharaEffects,
                            ICharaActivity,
                            IEventEmitter
                         })

IChara._type = "base.chara"

-- TODO schema

-- Must be available before generation.
local defaults = {
   level = 1,
   quality = 2,
}

-- Must be available after instantiation.
local fallbacks = {
   state = "Dead",
   experience = 0,
   sleep_experience = 0,
   dv = 0,
   pv = 0,
   hit_bonus = 0,
   damage_bonus = 0,
   curse_power = 0,
   critical_rate = 0,
   fov = 15,
   time_this_turn = 0,
   turns_alive = 0,
   armor_class = "",

   image = "",

   gold = 0,
   platinum = 0,

   number_of_weapons = 0,
   ether_disease_speed = 0,
   initial_x = 0,
   initial_y = 0,
   ai_config = {
      min_distance = 1,
      move_chance_percent = 100,
      sub_act_chance_percent = 10,
      follow_player_when_calm = false,

      on_low_hp = nil,
      on_idle_action = nil
   },

   known_abilities = {},

   hp = 1,
   mp = 1,
   stamina = 1,
   max_hp = 1,
   max_mp = 1,
   max_stamina = 1,

   nutrition = 0;

   pierce_chance = 0,
   physical_damage_reduction = 0,

   ai = "elona.elona_default_ai"
}

--- Initializes the bare minimum values on this character. All
--- characters must run this function on creation.
function IChara:pre_build()
   IMapObject.init(self)

   self.state = "Dead"

   -- NOTE: to add new interfaces/behaviors, connect_self to
   -- on_instantiate and run them there.
   IModdable.init(self)
   IEventEmitter.init(self)
   IFactioned.init(self)
   ICharaInventory.init(self)
   ICharaEquip.init(self)
   ICharaTalk.init(self)
   ICharaSkills.init(self)
   ICharaEffects.init(self)
   ICharaTraits.init(self)

   self:emit("base.on_pre_build")

   self:mod_base_with(defaults, "merge")
end

--- The default initialization logic for characters created through
--- Chara.create(). You can skip this by passing `no_build = true` in
--- the parameters to Chara.create(), but it becomes the caller's
--- responsibility to ensure that IChara:build() is also called at
--- some later point.
function IChara:normal_build()
   self:emit("base.on_normal_build")
end

--- Finishes initializing this character. All characters must run this
--- function sometime after running pre_build() before being used.
function IChara:build()
   self:mod_base_with(fallbacks, "merge")

   self.state = "Alive"

   self.target = nil

   self:reset_ai()

   self:emit("base.on_build_chara")

   self:refresh()

   self:heal_to_max()
end

function IChara:instantiate()
   IObject.instantiate(self)
   ICharaTalk.instantiate(self)

   Event.trigger("base.on_chara_instantiated", {chara=self})
end

function IChara:refresh()
   IModdable.on_refresh(self)
   IMapObject.on_refresh(self)
   ICharaEquip.on_refresh(self)
   ICharaTraits.on_refresh(self)

   self:refresh_weight()

   self:mod(
      "memory",
      {
         image = self:calc("image"),
         x = self.x,
         y = self.y
      }
   )

   if self:calc("max_hp") < 0 then
      self:mod("max_hp", 1, "set")
   end
   if self:calc("max_mp") < 0 then
      self:mod("max_mp", 1, "set")
   end

   self.hp = math.min(self.hp, self:calc("max_hp"))
   self.mp = math.min(self.mp, self:calc("max_mp"))
   self.stamina = math.min(self.stamina, self:calc("max_stamina"))

   local total_weight = self:calc("equipment_weight")
   local armor_class
   if total_weight >= 35000 then
      armor_class = "elona.heavy_armor"
   elseif total_weight >= 15000 then
      armor_class = "elona.medium_armor"
   else
      armor_class = "elona.light_armor"
   end
   self:mod("armor_class", armor_class)

   self:emit("base.on_refresh")
end

function IChara:on_refresh()
end

function IChara:produce_memory()
   return {
      uid = self.uid,
      state = self.state,
      image = self:calc("image") .. "#1"
   }
end

function IChara:copy_image()
   local chara_atlas = require("internal.global.atlases").get().chara
   return chara_atlas:copy_tile_image(self:calc("image") .. "#1")
end

-- Iterates both the character's inventory and equipment.
function IChara:iter_items()
   return fun.chain(self:iter_inventory(), self:iter_equipment())
end

function IChara:refresh_weight()
   local weight = 0
   for _, i in self:iter_items() do
      weight = weight + i:calc("weight")
   end
   self:mod("inventory_weight", weight)
   self:mod("max_inventory_weight", 1000)
end

function IChara:set_pos(x, y)
   if Chara.at(x, y) ~= nil then
      return false
   end

   return IMapObject.set_pos(self, x, y)
end

function IChara:is_player()
   return field.player == self.uid
end

function IChara:is_ally()
   return fun.iter(save.base.allies):index(self.uid) ~= nil
end

function IChara:recruit_as_ally()
   if self:is_ally() then
      return false
   end
   save.base.allies[#save.base.allies+1] = self.uid

   self.faction = "base.friendly"
   self:refresh()

   Gui.mes(self.uid .. " joins as an ally! ", "Orange")
   Gui.play_sound("base.pray1");
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

local calc_damage = Event.define_hook("calc_damage", "Calculates damage.", 0)

local calc_applied_damage = Event.define_hook("calc_applied_damage",
[[
Calculates the actual damage dealt, separate from base damage which is used to calculate things like gained skill experience.
]] ,
                                              0)

function IChara:damage_hp(amount, source, params)
   params = params or {}

   local element = nil
   if type(params.element) == "string" then
      element = data["base.element"][params.element]
   end

   local victim = self

   local attacker = nil
   if type(source) == "table" and source._type == "base.chara" then
      attacker = source
   end

   local event_params = {
      chara = victim,
      original_damage = amount,
      source = source,
      attacker = attacker, -- TODO remove/replace with source
      element = element,

      element_power = params.element_power or 0,

      -- only required for message printing
      message_tense = params.message_tense or "passive",
      extra_attacks = params.extra_attacks or 0,
      weapon = params.weapon or nil,
   }

   if not Chara.is_alive(victim) then
      victim:emit("base.after_damage_hp", event_params)
      return true, 0
   end

   local damage = amount
   event_params.damage = damage

   damage = victim:emit("base.hook_calc_damage", event_params, damage)
   event_params.damage = damage

   local base_damage = damage
   event_params.base_damage = base_damage
   damage = victim:emit("base.hook_calc_applied_damage", event_params, damage)
   event_params.damage = damage

   victim.hp = math.min(victim.hp - math.floor(damage), victim.max_hp)

   victim:emit("base.after_chara_damaged", event_params)

   if victim.hp >= 0 then
      victim:emit("base.on_damage_chara", event_params)
   end

   local killed = false
   if victim.hp < 0 then
      victim:kill(source)

      victim:emit("base.on_kill_chara", event_params)

      killed = not Chara.is_alive(victim)
   end

   victim:emit("base.after_damage_hp", event_params)

   return killed, base_damage, damage
end

Event.register("base.on_damage_chara", "Interrupt activity", function(chara) chara:interrupt_activity() end)

function IChara.after_chara_damaged(victim, params)
   local element = params.element
   if element and element.after_apply_damage then
      element.after_apply_damage(victim, params)
   end
end
Event.register("base.after_chara_damaged", "Apply element damage.", IChara.after_chara_damaged)

function IChara.on_kill_chara(victim, params)
   local attacker = params.attacker
   Gui.play_sound(Rand.choice({"base.kill1", "base.kill2"}), victim.x, victim.y)

   if attacker then
      local gained_exp = victim:emit("base.on_calc_kill_exp", params, 0)

      -- TODO chara:gain_experience() to allow global experience
      -- modifier
      attacker.experience = attacker.experience + gained_exp
      if attacker:is_player() then
         attacker.sleep_experience = attacker.sleep_experience + gained_exp
      end
      if attacker:is_in_party() then
         attacker:set_target(nil)
         attacker:get_party_leader():set_target(nil)
      end
   end
end
Event.register("base.on_kill_chara", "Default kill handler.", IChara.on_kill_chara)

function IChara.apply_hostile_action(victim, params)
   local attacker = params.attacker

   if attacker then
      attacker:act_hostile_towards(victim)
   end

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
Event.register("base.on_damage_chara", "Hostile action towards AI", IChara.apply_hostile_action)

function IChara.apply_element_on_damage(victim, params)
   if params.element and params.element.on_damage then
      params.element.on_damage(victim, params)
   end
end
Event.register("base.on_damage_chara", "Element on_damage effects", IChara.apply_element_on_damage)

function IChara:damage_sp(amount)
   self.stamina = math.max(self.stamina - amount, -100)
end

function IChara:heal_hp(add)
   self.hp = math.min(self.hp + math.max(add, 0), self:calc("max_hp"))
end

function IChara:heal_mp(add)
   self.mp = math.min(self.mp + math.max(add, 0), self:calc("max_mp"))
end

function IChara:heal_sp(add)
   self.stamina = math.max(self.stamina + math.max(add, 0), self:calc("max_stamina"))
end

function IChara:heal_to_max()
   self.hp = self:calc("max_hp")
   self.mp = self:calc("max_mp")
   self.stamina = self:calc("max_stamina")
end

function IChara:kill(source)
   if not Chara.is_alive(self) then
      return
   end

   if class.is_an(IChara, source) then
      local death_type = Rand.rnd(4)
   else
      if source and source.get_death_cause then
         local death_cause = source.get_death_cause()
      else
      end
   end

   Event.trigger("base.on_chara_killed", {chara=self,source=source})

   self.state = "Dead"
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

function IChara:reset_ai()
   self.target = nil

   self.ai_state = {
      hate = 0,
      leader_attacker = nil,
      item_to_be_used = nil,
      wants_movement = 0,
      last_target_x = 0,
      last_target_y = 0,
      anchor_x = nil,
      anchor_y = nil,
      is_anchored = false,
   }
end

function IChara:get_target()
   return self.target
end

--
--
-- Elona
--
--

-- TEMP
function IChara:status_ailment_turns(status_ailment)
   return 0
end

-- TEMP
function IChara:has_status_ailment(status_ailment)
   return self:status_ailment_turns(status_ailment) > 0
end

function IChara:is_in_fov()
   local map = self:current_map()
   if not map then
      return false
   end

   return map:is_in_fov(self.x, self.y)
end

Codegen.generate_object_getter(IChara, "ammo", "base.item")

function IChara:calc_initial_gold()
   return Rand.rnd(self:calc("level") * 25 + 10) + 1
end

return IChara
