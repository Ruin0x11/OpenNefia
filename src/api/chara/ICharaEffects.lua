local data = require("internal.data")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local I18N = require("api.I18N")

local ICharaEffects = class.interface("ICharaEffects")

function ICharaEffects:init()
   self.effects = {}
   self.effect_immunities = {}
end

function ICharaEffects:effect_turns(id)
   data["base.effect"]:ensure(id)

   return self:calc("effects")[id] or 0
end

function ICharaEffects:add_effect_immunity(id)
   data["base.effect"]:ensure(id)

   self.temp["effect_immunities"] = self.temp["effect_immunities"]
      or table.deepcopy(self.effect_immunities or {})

   self.temp["effect_immunities"][id] = true
end

function ICharaEffects:is_immune_to_effect(id)
   data["base.effect"]:ensure(id)

   self.temp["effect_immunities"] = self.temp["effect_immunities"]
      or table.deepcopy(self.effect_immunities or {})

   return not not self:calc("effect_immunities")[id]
end

function ICharaEffects:has_effect(id)
   return self:effect_turns(id) > 0
end

function ICharaEffects:set_effect_turns(id, turns, force)
   local effect_proto = data["base.effect"]:ensure(id)

   if self:is_immune_to_effect(id) and not force then
      self.effects[id] = nil
      return false
   end

   local has_effect = self:has_effect(id)
   self.effects[id] = turns
   if self.effects[id] <= 0 then
      if has_effect and effect_proto.on_remove then
         effect_proto.on_remove(self)
      end
      self.effects[id] = nil
   else
      if not has_effect and effect_proto.on_add then
         effect_proto.on_add(self)
      end
   end

   return true
end

function ICharaEffects:add_effect_turns(id, turns)
   self:set_effect_turns(id, self:effect_turns(id) + turns)
end

function ICharaEffects:remove_effect(id)
   self:set_effect_turns(id, 0)
end

function ICharaEffects:remove_all_effects()
   self.effects = {}
end

local function calc_power_after_resistance(chara, effect, element, power)
   local resistance = chara:resist_level(element._id)
   local level = math.floor(resistance / 50)
   power = (Rand.rnd(math.floor(power / 2) + 1) + math.floor(power / 2)) * 100 / (50 + level * 50)

   if level >= 3 and power < 40 then
      return 0
   end

   return power
end

local function calc_effect_power_resist(chara, params, power)
   local effect = params.effect

   if effect.related_element ~= nil then
      local element = data["base.element"][effect.related_element]
      if element ~= nil then
         power = calc_power_after_resistance(chara, effect, element, power)
      end
   end

   return power
end
Event.register("elona_sys.calc_effect_power",
               "Effect power from elemental resistance",
               calc_effect_power_resist)

local function calc_effect_power_reduction(chara, params, power)
   local reduction = params.effect.power_reduction_factor or 1
   return math.floor(power / reduction)
end
Event.register("elona_sys.calc_effect_power",
               "Effect power from power reduction",
               calc_effect_power_reduction)

function ICharaEffects:apply_effect(id, power, params)
   power = power or 10
   params = params or {}

   if power <= 0 then
      return
   end

   local effect = data["base.effect"]:ensure(id)

   if effect.before_apply ~= nil then
      if effect.before_apply() == false then
         return false
      end
   end

   power = self:emit("elona_sys.calc_effect_power", {effect=effect}, power)

   local turns = power

   if turns <= 0 then
      return false
   end

   local current = self:effect_turns(id)
   local success

   if current == nil or current <= 0 then
      success = self:set_effect_turns(id, turns)
      if success and not params.no_message then
         local key = "effect." .. id .. ".apply"
         if I18N.get_optional(key) then
            Gui.mes_c_visible(key, self, "Purple")
         end
      end
   else
      local additive = effect.additive_power
      if type(additive) == "function" then
         additive = math.floor(additive({turns=turns}))
      end
      additive = additive or turns

      turns = current + additive
      success = self:set_effect_turns(id, turns)
   end

   -- TODO
   self:emit("elona_sys.on_apply_effect", {effect=effect,turns=turns,prev_turns=current,immune=(not success)})

   return true
end

Event.register("elona_sys.on_apply_effect", "Stop activity", function(chara, params)
                  if params.effect.stops_activity then
                     chara:remove_activity()
                  end
end)

function ICharaEffects:heal_effect(id, power, params)
   params = params or {}
   power = power or 0

   if power < 0 then
      return false
   end

   local effect = data["base.effect"]:ensure(id)

   local current = self:effect_turns(id)
   local turns = current - power

   local success
   if power == 0 then
      success = self:set_effect_turns(id, 0)
   else
      success = self:set_effect_turns(id, turns)
   end
   if success and not params.no_message and current > 0 and turns <= 0 then
      Gui.mes_visible(self.uid .. " healed effect " .. id .. " completely. ", self.x, self.y)
      Gui.mes_visible("effect." .. id .. ".heal", self)
   end

   self:emit("elona_sys.on_heal_effect", {effect=effect,turns=turns,prev_turns=current,immune=(not success)})

   return true
end

return ICharaEffects
