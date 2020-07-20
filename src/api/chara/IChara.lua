--- @classmod IChara

local data = require("internal.data")
local field = require("game.field")
local Chara = require("api.Chara")
local Codegen = require("api.Codegen")
local Rand = require("api.Rand")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Map = require("api.Map")
local I18N = require("api.I18N")
local ICharaEffects = require("api.chara.ICharaEffects")
local ICharaEquip = require("api.chara.ICharaEquip")
local ICharaInventory = require("api.chara.ICharaInventory")
local ICharaParty = require("api.chara.ICharaParty")
local ICharaActivity = require("api.chara.ICharaActivity")
local ICharaSkills = require("api.chara.ICharaSkills")
local ICharaTraits = require("api.chara.ICharaTraits")
local ICharaBuffs = require("api.chara.ICharaBuffs")
local IObject = require("api.IObject")
local ILocalizable = require("api.ILocalizable")
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
                            ILocalizable,
                            IFactioned,
                            IEventEmitter,
                            ICharaInventory,
                            ICharaTalk,
                            ICharaEquip,
                            ICharaParty,
                            ICharaSkills,
                            ICharaTraits,
                            ICharaEffects,
                            ICharaActivity,
                            ICharaBuffs
                         })

IChara._type = "base.chara"

-- TODO schema

-- Must be available before generation.
local defaults = {
   level = 1,
   quality = 2,
}

--- Initializes the bare minimum values on this character. All
--- characters must run this function on creation.
function IChara:pre_build()
   IMapObject.init(self)

   self.state = "Dead"
   self.name = I18N.get_optional("chara." .. self._id .. ".name") or self.name

   -- NOTE: to add new interfaces/behaviors in mods, connect_self to
   -- base.on_pre_build and run their init() functions there.
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
   local fallbacks = data.fallbacks["base.chara"]
   self:mod_base_with(table.deepcopy(fallbacks), "merge")

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

   self:emit("base.on_chara_instantiated")
end

--- Refreshes this character, resetting all moddable data.
---
--- @overrides IMapObject.refresh
function IChara:refresh()
   IModdable.on_refresh(self)
   IMapObject.on_refresh(self)
   ICharaEquip.on_refresh(self)
   ICharaSkills.on_refresh(self)
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

--- @overrides IMapObject:on_refresh
function IChara:on_refresh()
end

local PCC_DIRS = {
   South = 1,
   West = 2,
   East = 3,
   North = 4,
   Northwest = 4,
   Northeast = 4,
   Southwest = 1,
   Southeast = 1,
}

--- @treturn[opt] table
--- @overrides IMapObject:produce_memory
function IChara:produce_memory()
   local hp_bar = "hp_bar_other"
   if self:is_allied() then
      hp_bar = "hp_bar_ally"
   end

   local x_offset = self:calc("x_offset")
   local y_offset = self:calc("y_offset")
   local image
   if self.pcc then
      self.pcc.dir = PCC_DIRS[self.direction] or 4
      self.pcc.frame = self.turns_alive % 4 + 1
      image = self.pcc
   else
      image = (self:calc("image") or "")
      local image_data = data["base.chip"][image]
      if image_data then
         y_offset = y_offset or image_data.y_offset
      end
   end

   return {
      uid = self.uid,
      show = Chara.is_alive(self, self:current_map()),
      image = image,
      color = self:calc("color"),
      x_offset = x_offset or nil,
      y_offset = y_offset or nil,
      hp_bar = hp_bar,
      hp_ratio = self:calc("hp") / self:calc("max_hp"),
      shadow_type = "normal",
      drawables = self.drawables
   }
end

--- @treturn table
--- @overrides ILocalizable:produce_locale_data
function IChara:produce_locale_data()
   return {
      name = self:calc("name"),
      gender = self:calc("gender"),
      is_player = self:is_player(),
      is_visible = self:is_in_fov(),
      has_own_name = self:calc("has_own_name"),
      talk_type = self:calc("talk_type")
   }
end

--- Iterates both the character's inventory and equipment.
---
--- @treturn Iterator(IItem)
function IChara:iter_items()
   return fun.chain(self:iter_inventory(), self:iter_equipment())
end

function IChara:refresh_weight()
   local weight = 0
   local cargo_weight = 0
   for _, i in self:iter_items() do
      weight = weight + i:calc("weight")
      cargo_weight = cargo_weight + i:calc("cargo_weight")
   end
   self.inventory_weight = weight
   self.cargo_weight = cargo_weight
   self.max_inventory_weight = 45000
   self.inventory_weight_type = 0
   self:emit("base.on_refresh_weight")
end

--- Sets this character's position. Use this function instead of updating x and y manually.
---
--- @tparam int x
--- @tparam int y
--- @tparam bool force
--- @treturn bool true on success.
--- @overrides IMapObject.set_pos
function IChara:set_pos(x, y, force)
   local map = self:current_map()
   if not map then
      return false
   end

   if not Map.can_access(x, y, map) and not force then
      return false
   end

   return IMapObject.set_pos(self, x, y, force)
end

--- Returns true if this character is the current player.
---
--- @treturn bool
function IChara:is_player()
   return field.player and field.player.uid == self.uid
end

--- Returns true if this character is an ally of the player.
---
--- @treturn bool
function IChara:is_ally()
   return fun.iter(save.base.allies):index(self.uid) ~= nil
end

--- Attempts to recruit this character as an ally.
---
--- @tparam bool no_message
--- @treturn bool true on success.
function IChara:recruit_as_ally(no_message)
   if self:is_ally() then
      return false
   end
   save.base.allies[#save.base.allies+1] = self.uid

   self.faction = "base.friendly"
   self:refresh()

   if not no_message then
      Gui.mes_c("action.ally_joins.success", "Yellow", self)
      Gui.play_sound("base.pray1");
   end
   self:emit("base.on_recruited_as_ally", { no_message = no_message })
   return true
end

--- Swaps the positions of this character with another.
---
--- @tparam IMapObject other
--- @treturn b ool true on success.
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

--- Damages this character.
---
--- @tparam int amount Base amount of damage to inflict.
--- @tparam[opt] string|IChara source The source of damage. Can be a
---   string or another character.
--- @tparam[opt] table params Extra parameters.
---  - element (id:base.element): The element of the damage.
---  - element_power (int): The power of the elemental damage.
---  - weapon (IItem): The item used to inflict the damage.
---  - message_tense (string): Either "passive" or "active".
---  - extra_attacks (int): Number of extra attacks to apply.
function IChara:damage_hp(amount, source, params)
   params = params or {}

   local element = nil
   if params.element then
      assert(type(params.element) == "string")
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
      is_third_person = params.is_third_person,
      no_attack_text = params.no_attack_text,
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
   damage = math.floor(damage)
   event_params.damage = damage

   local base_damage = damage
   event_params.base_damage = base_damage
   damage = victim:emit("base.hook_calc_applied_damage", event_params, damage)
   event_params.damage = damage

   victim.hp = math.min(victim.hp - math.floor(damage), victim:calc("max_hp"))

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
      if victim:reaction_towards(attacker) < 0 or attacker:base_reaction_towards(victim) < 0 then
         if victim.ai_state.hate == 0 and Rand.one_in(4) then
            apply_hate = true
         end
      end
      if not attacker:is_player() and attacker:get_target() == victim and Rand.one_in(3) then
         apply_hate = true
      end

      if apply_hate then
         if victim:get_reaction_at(attacker) == 0 then
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

--- Damages this character's mana points.
---
--- @tparam int amount
--- @tparam boolean no_magic_reaction
--- @tparam boolean quiet
function IChara:damage_mp(amount, no_magic_reaction, quiet)
   self.mp = math.floor(math.max(self.mp - amount, -999999))
   self:emit("base.on_damage_chara_mp", { amount = amount, no_magic_reaction = no_magic_reaction, quiet = quiet })
end

local function magic_reaction(source, p)
   if source.mp < 0 and not p.no_magic_reaction then
      source:emit("base.on_magic_reaction", {})
      local Skill = require("mod.elona_sys.api.Skill")
      Skill.gain_skill_exp(source, "elona.magic_capacity", math.abs(source.mp) * 200 / (source:calc("max_mp") + 1))
      local damage = (source.mp * -1) * 400 / (100 + source:skill_level("elona.magic_capacity") * 10)
      if source:is_player() then
         if source:has_trait("elona.perm_capacity") then
            damage = damage / 2
         end
      else
         damage = damage / 5
         if damage < 10 then
            return
         end
      end
      Gui.mes("damage.magic_reaction_hurts", source)
      source:damage_hp(damage, "elona.magic_overcast")
   end
end
Event.register("base.on_damage_chara_mp", "Magic reaction", magic_reaction)

--- Damages this character's stamina points.
---
--- @tparam int amount
function IChara:damage_sp(amount)
   self.stamina = math.floor(math.max(self.stamina - amount, -100))
end

--- Heals this character's hit points.
---
--- @tparam int add
--- @tparam boolean quiet
function IChara:heal_hp(add, quiet)
   self.hp = math.floor(math.min(self.hp + math.max(add, 0), self:calc("max_hp")))
   self:emit("base.on_heal_chara_hp", { amount = add, quiet = quiet })
end

--- Heals this character's mana points.
---
--- @tparam int add
--- @tparam boolean quiet
function IChara:heal_mp(add, quiet)
   self.mp = math.floor(math.min(self.mp + math.max(add, 0), self:calc("max_mp")))
   self:emit("base.on_heal_chara_mp", { amount = add, quiet = quiet })
end

--- Heals this character's stamina points.
---
--- @tparam int add
function IChara:heal_stamina(add)
   self.stamina = math.floor(math.max(self.stamina + math.max(add, 0), self:calc("max_stamina")))
end

--- Fully heals this character's health, mana and stamina.
function IChara:heal_to_max()
   self.hp = self:calc("max_hp")
   self.mp = self:calc("max_mp")
   self.stamina = self:calc("max_stamina")
end

--- Kills this character, moving it to the "dead" state. Like
--- IChara:damage_hp, a damage source can be provided.
---
--- @tparam[opt] string|IChara source
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

   if self:is_ally() then
      self.state = "PetDead"
      -- TODO modify impression/bodyguard/is escorting
   elseif next(self.roles) then
      self.state = "CitizenDead"
   else
      self.state = "Dead"
   end
   self.is_solid = nil

   local map = self:current_map()
   if map then
      map:refresh_tile(self.x, self.y)
   end

   self:emit("base.on_chara_killed", {source=source})
end

--- Removes this character completely.
function IChara:vanquish()
   if self:is_player() then
      return
   end

   self.state = "Dead"
   self.is_solid = nil

   local map = self:current_map()
   if map then
      map:refresh_tile(self.x, self.y)
   end

   if self:is_ally() then
      table.iremove_value(save.base.allies, self.uid)
   end

   self:emit("base.on_chara_vanquished")
end

--- Revives this character.
--- @treturn bool
function IChara:revive()
   if Chara.is_alive(self) then
      return false
   end

   self.state = "Alive"
   self.is_solid = true
   self.hp = math.floor(self:calc("max_hp") / 3)
   self.mp = math.floor(self:calc("max_mp") / 3)
   self.stamina = math.floor(self:calc("max_stamina") / 3)
   self:reset("is_pregnant", false)
   self:reset("is_anorexic", false)
   self.insanity = 0
   self.nutrition = 8000
   self.personal_reactions = {}

   self:renew_status()

   self:emit("base.on_chara_revived")

   return true
end

function IChara:renew_status()
   self:remove_activity()
   self:remove_all_effects()
   self:remove_all_buffs()
   self.emotion_icon = nil
   self.emotion_icon_turns = 0
   self.stat_adjusts = {}
   self.ai_state.hate = 0

   self:refresh()
end

--- Revives this character and moves them to the current/given map.
---
--- @tparam[opt] InstancedMap map
function IChara:revive_and_place(map)
   if not self:revive() then
      return false
   end

   map = map or Map.current()
   if map == nil then
      return false
   end

   Map.try_place_chara(self, nil, nil, map)

   Gui.play_sound("base.pray1")
   Gui.mes(self.uid .. " has revived!")

   return true
end

--- Sets or clears the AI target of this character.
---
--- @tparam[opt] IChara target
function IChara:set_target(target)
   self.target = target
end

--- Resets the AI state of this character.
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

   self:reset_all_reactions()
end

--- @treturn[opt] IChara
function IChara:get_target()
   return self.target
end

--- Clears all status effects, stat adjustments, activities and AI
--- targets, and refreshes the character,
function IChara:clear_status_effects()
   self.effects = {}
   self.stat_adjusts = {}
   self.ai_state.hate = 0
   self.target = nil
   self:remove_activity()

   self:refresh()
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

Codegen.generate_object_getter(IChara, "ammo", "base.item")

function IChara:calc_initial_gold()
   return Rand.rnd(self:calc("level") * 25 + 10) + 1
end

function IChara:has_role(role)
   return self.roles[role] ~= nil
end

function IChara:set_emotion_icon(icon, duration)
   self.emotion_icon = icon
   self.emotion_icon_turns = duration or 2
end

return IChara
