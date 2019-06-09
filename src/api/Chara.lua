local Ai = require("api.Ai")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Log = require("api.Log")
local Map = require("api.Map")
local Pos = require("api.Pos")
local Rand = require("api.Rand")

local chara = require("internal.chara")
local data = require("internal.data")
local field = require("game.field")

-- Functions for manipulating characters.
local Chara = {}

function Chara.at(x, y)
   if not Map.is_in_bounds(x, y) then
      return nil
   end
   local objs = field.map:objects_at("base.chara", x, y)
   assert(objs ~= nil, string.format("%d,%d", x, y))

   local chara
   local count = 0
   for _, id in ipairs(objs) do
      local v = field.map:get_object("base.chara", id)
      if Chara.is_alive(v) then
         chara = v
         count = count + 1
      end
   end

   assert(count <= 1, "More than one live character on tile: " .. inspect(objs))

   return chara
end

function Chara.set_pos(c, x, y)
   if type(c) ~= "table" or not field:exists(c) then
      Log.warn("Chara.set_pos: Not setting position of %s to %d,%d", tostring(c), x, y)
      return false
   end

   if not Map.is_in_bounds(x, y) then
      return false
   end

   if Chara.at(x, y) ~= nil then
      return false
   end

   field.map:move_object(c, x, y)

   return true
end

function Chara.move(c, dx, dy)
   return Chara.set_pos(c, c.x + dx, c.y + dy)
end

function Chara.is_player(c)
   return type(c) == "table" and field.player.uid == c.uid
end

function Chara.player()
   return field.player
end

function Chara.set_player(c)
   assert(type(c) == "table")
   field.player = c

   c.original_relation = "friendly"
   c.relation = chara.original_relation

   c.max_hp = 500
   c.max_mp = 100
   c.hp = c.max_hp
   c.mp = c.max_mp
end

function Chara.delete(c)
   field.map:remove_object(c)
end

function Chara.kill(c)
   -- Persist based on character type.
   c.state = "Dead"
end

function Chara.is_alive(c)
   -- Persist based on character type.
   return type(c) == "table" and c.state == "Alive"
end

local function init_chara(chara)
   -- TODO remove and place in schema as defaults
   chara.hp = chara.max_hp
   chara.mp = chara.max_mp
   chara.batch_ind = 0
   chara.tile = chara.image
   chara.state = "Alive"
   chara.time_this_turn = 0
   chara.turns_alive = 0
   chara.level = 1
   local Great = 3
   chara.quality = Great

   chara.initial_x = 0
   chara.initial_y = 0

   chara.experience = 0
   chara.sleep_experience = 0

   chara.stats = {}
   chara.stats["base.speed"] = {
      level = 100,
      original_level = 100
   }

   chara.ai_config = {
      on_low_hp = nil,
   }
   chara.original_relation = "enemy"
   chara.relation = chara.original_relation

   local IAi = require("api.IAi")
   local ElonaAi = require("api.ElonaAi")
   chara.ai = ElonaAi:new(chara.ai_config)
   assert_is_an(IAi, chara.ai)
end

function Chara.create(id, x, y)
   if field.map == nil then return nil end

   if not Map.is_in_bounds(x, y) then
      return nil
   end

   if Chara.at(x, y) ~= nil then
      return nil
   end

   local proto = data["base.chara"][id]
   if proto == nil then return nil end

   assert(type(proto) == "table")

   local chara = field.map:create_object(proto, x, y)

   -- TODO remove
   init_chara(chara)

   return chara
end

-- Gets the level of a stat after applying modifiers.
function Chara.stat(c, stat_id)
   if not Chara.is_alive(c) then
      return 0
   end
   local stat = c.stats[stat_id]
   if stat == nil then
      return 0
   end

   -- TODO: determine how stats are calculated.
   --
   -- It is probably complex to keep a system of chainable expiring
   -- modifiers. We could keep Elona's system of simply requesting a
   -- refresh when desired.
   return stat.level
end

function Chara.is_ally(c)
   return false
end

function Chara.is_in_party(c)
   return Chara.is_player(c) or Chara.is_ally(c)
end

function Chara.swap_positions(a, b)
   -- EVENT: on_swap_chara_positions

   local ax, ay = a.x, a.y
   local bx, by = b.x, b.y
   field.map:move_object(a, bx, by)
   field.map:move_object(b, ax, ay)

   return true
end

local function show_element_text_damage(victim, source, victim, element)
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

function Chara.damage_hp(victim, amount, source, params)
   params = params or {}

   local event_params = {
      victim = victim,
      amount = amount,
      source = source,
      params = params
   }

   local attacker = nil
   if type(source) == "table" and source._type == "base.chara" then
      attacker = source
   end

   local attacker_is_player = Chara.is_player(attacker)

   if not Chara.is_alive(victim) then
      Event.trigger("base.after_damage_hp", event_params)
      return true
   end

   local damage = amount

   local element
   if params.element then
      element = data["base.element"][element]
   end

   if element and element.can_resist then
      local resistance = 0

      if resistance < 3 then
         damage = math.floor(damage * 150 / math.clamp(resistance * 50 + 50, 40, 150))
      elseif resistance < 10 then
         damage = math.floor(damage * 100 / resistance * 50 + 50)
      else
         damage = 0
      end

      local magic_resistance = 0
      damage = math.floor(damage * 100 / (magic_resistance / 2 + 50))
   end

   if attacker_is_player then
      if params.critical then
      else
      end
   end

   event_params.damage = damage

   local result = Event.trigger("base.on_calc_damage", event_params)
   if type(result.damage) == "number" then
      damage = result.damage
   end

   victim.hp = math.min(victim.hp - damage, victim.max_hp)

   Event.trigger("base.after_apply_damage", event_params)

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

      -- TODO: interrupt activity
      -- fear

      if element then
         if element.on_damage_hp then
            element:on_damage_hp(victim, source, params.element_power or 0)
         end
      end

      if attacker_is_player then
         Ai.act_hostile_towards(attacker, victim)
      end

      -- heartbeat
      -- explodes
      -- splits
      -- quick tempered

      if attacker and not Chara.is_player(victim) then
         local apply_hate
         if Ai.relation_towards(victim, attacker) == "enemy" or attacker.original_relation == "enemy" then
            if Ai.hate_towards(victim, attacker) == 0 and Rand.one_in(4) then
               apply_hate = true
            end
         end
         if not attacker_is_player and Ai.get_target(attacker) == victim and Rand.one_in(3) then
            apply_hate = true
         end

         if apply_hate then
            if Ai.hate_towards(victim, attacker) == 0 then
               Ai.send_event(victim, "base.turn_hostile", { hate = 20 })
            else
               Ai.send_event(victim, "base.modify_hate", { hate_delta = 2 })
            end
         end
      end
   end

   local killed = false
   if victim.hp < 0 then
      killed = true

      if attacker then
         if element then
            if not Chara.is_ally(victim) and params.damage_text_type == "element" then
            else
            end
         else
            local death_type = Rand.rnd(4)
            Gui.mes(victim.uid .. " was killed.")
         end
      else
         if source.get_death_cause then
            local death_cause = source.get_death_cause()
         else
            Gui.mes(victim.uid .. " dies.")
         end
      end

      victim.state = "Dead"

      Event.trigger("base.on_chara_killed", event_params)

      if attacker then
         local gained_exp = calc_kill_exp(attacker, victim)

         attacker.experience = attacker.experience + gained_exp
         -- TODO sleep exp
         if Chara.is_ally(attacker) then
            Ai.set_target(attacker, nil)
            Ai.set_target(Chara.player(), nil)
         end
      end

      -- on kill quest chara
      -- TODO: block if void/showroom
      if not Chara.is_player(victim) then
         if victim.on_death then
            victim.on_death(damage, source)
         end
      end
   end

   Event.trigger("base.after_damage_hp", event_params)

   return killed
end

return Chara
