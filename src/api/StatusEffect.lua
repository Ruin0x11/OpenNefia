local data = require("internal.data")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Map = require("api.Map")
local Gui = require("api.Gui")
local Log = require("api.Log")
local Rand = require("api.Rand")

local StatusEffect = {}

function StatusEffect.calc_power_after_resistance(victim, status_effect, element, power)
   local resistance = 0
   local level = math.floor(resistance / 50)
   power = (Rand.rnd(math.floor(power / 2) + 1) + math.floor(power / 2)) * 100 / (50 + level * 50)

   if level >= 3 and power < 40 then
      return 0
   end

   return power
end

function StatusEffect.get_turns(victim, id)
   local status_effect = data["base.status_effect"][id]
   if status_effect == nil then
      Log.warn("Unknown status effect %s", id)
      return 0
   end

   return victim.status_effects[id] or 0
end

function StatusEffect.set_turns(victim, id, turns)
   local status_effect = data["base.status_effect"][id]
   if status_effect == nil then
      Log.warn("Unknown status effect %s", id)
      return
   end

   turns = math.max(turns, 0)
   if turns == 0 then
      victim.status_effects[id] = nil
   else
      victim.status_effects[id] = turns
   end
end

function StatusEffect.modify_turns(victim, id, delta)
   StatusEffect.set_turns(victim, id, StatusEffect.get_turns(victim, id) + delta)
end

function StatusEffect.apply(victim, id, power)
   if power <= 0 then
      return
   end

   local status_effect = data["base.status_effect"][id]
   if status_effect == nil then
      Log.warn("Unknown status effect %s", id)
      return false
   end

   if status_effect.before_apply ~= nil then
      if status_effect.before_apply() == false then
         return false
      end
   end

   if status_effect.related_element ~= nil then
      local element = data["base.element"][status_effect.related_effect]
      if element ~= nil and element.can_resist then
         power = StatusEffect.calc_power_after_resistance(victim, status_effect, element, power)
      end
   end

   local reduction = status_effect.power_reduction_factor or 1
   local turns = math.floor(power / reduction)

   if turns <= 0 then
      return false
   end

   local current = StatusEffect.get_turns(victim, id)

   if current == nil or current <= 0 then
      StatusEffect.set_turns(victim, id, turns)
      Gui.mes(victim.uid .. " is applied " .. id .. ". ")
   else
      local additive = status_effect.additive_power
      if type(additive) == "function" then
         additive = math.floor(additive({turns=turns}))
      end
      additive = additive or turns

      StatusEffect.set_turns(victim, id, current + additive)
   end

   -- TODO: interrupt activity

   return true
end

function StatusEffect.heal(victim, id, power)
   power = power or 0

   if power < 0 then
      return false
   end

   local status_effect = data["base.status_effect"][id]
   if status_effect == nil then
      Log.warn("Unknown status effect %s", id)
      return false
   end

   local current = StatusEffect.get_turns(victim, id)

   if power == 0 then
      StatusEffect.set_turns(victim, id, 0)
   else
      StatusEffect.set_turns(victim, id, current - power)
   end
   if current - power <= 0 then
      if Map.is_in_fov(victim.x, victim.y) then
         Gui.mes(victim.uid .. " healed effect " .. id .. " completely. ")
      end
   end

   return true
end

function StatusEffect.proc_turn_begin(victim)
   local params = { victim = victim, turn_result = nil }

   for id, turns in pairs(victim.status_effects) do
      local status_effect = data["base.status_effect"][id]
      if status_effect == nil then
         Log.warn("Unknown status effect %s", id)
      elseif status_effect.on_turn_end and Chara.is_alive(victim) then
         params.turns = turns or 0
         params.status_effect = status_effect

         -- HACK
         params = table.merge(params, status_effect.on_turn_begin(params))
      end
   end

   return params.turn_result
end

function StatusEffect.proc_turn_end(victim)
   local params = { regeneration = true, victim = victim }

   for id, turns in pairs(victim.status_effects) do
      local status_effect = data["base.status_effect"][id]
      if status_effect == nil then
         Log.warn("Unknown status effect %s", id)
      elseif status_effect.on_turn_end and Chara.is_alive(victim) then
         params.turns = turns or 0
         params.status_effect = status_effect

         -- TODO: unify these two.
         params = table.merge(params, status_effect.on_turn_end(params))
         Event.trigger("base.on_proc_status_effect", params)
      end
   end

   return params.regeneration
end

return StatusEffect
