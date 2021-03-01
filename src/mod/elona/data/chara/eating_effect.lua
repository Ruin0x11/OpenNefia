local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Effect = require("mod.elona.api.Effect")
local Skill = require("mod.elona_sys.api.Skill")
local Hunger = require("mod.elona.api.Hunger")

local eating_effect = {}

local function eat_message(chara, locale_id, color)
   if chara:is_in_fov() then
      Gui.mes_c("food.effect.corpse." .. locale_id, color, chara)
   end
end

local function mod_resist_chance(chara, elem, chance)
   if Rand.one_in(chance) then
      Skill.modify_resist_level(elem, 50)
   end
end


function eating_effect.iron(corpse, params)
   eat_message(params.chara, "iron", "Purple")
   params.chara:apply_effect("elona.dimming", 200)
end

function eating_effect.deformed_eye(corpse, params)
   eat_message(params.chara, "deformed_eye", "Purple")
   Effect.damage_insanity(params.chara, 25)
   params.chara:apply_effect("elona.insanity", 500)
end

function eating_effect.horse(corpse, params)
   eat_message(params.chara, "horse", "Green")
   Skill.gain_skill_exp(params.chara, "elona.stat_constitution", 100)
end

function eating_effect.holy_one(corpse, params)
   eat_message(params.chara, "holy_one", "Green")
   Effect.damage_insanity(params.chara, 50)
   mod_resist_chance(params.chara, "elona.mind", 5)
end

function eating_effect.at(corpse, params)
   eat_message(params.chara, "at", "None")
end

function eating_effect.guard(corpse, params)
   if not params.chara:is_player() then
      return
   end
   eat_message(params.chara, "guard", "Purple")
   Effect.modify_karma(params.chara, -15)
end

function eating_effect.vesda(corpse, params)
   if not params.chara:is_player() then
      return
   end
   eat_message(params.chara, "vesda", "Green")
   params.Skill.modify_resist_level("elona.fire", 100)
end

function eating_effect.insanity(corpse, params)
   eat_message(params.chara, "insanity", "Purple")
   params.Skill.modify_resist_level("elona.mind", 50)
   Effect.damage_insanity(params.chara, 500)
   params.chara:apply_effect("elona.insanity", 1000)
end

function eating_effect.putit(corpse, params)
   eat_message(params.chara, "putit", "Green")
   Skill.gain_skill_exp(params.chara, "elona.stat_charisma", 150)
end

function eating_effect.cupid_of_love(corpse, params)
   eat_message(params.chara, "cupid_of_love", "Green")
   Skill.gain_skill_exp(params.chara, "elona.stat_charisma", 400)
end


local function eating_effect_poisonous(gain_resist)
   return function(corpse, params)
      eat_message(params.chara, "poisonous", "Purple")
      params.chara:apply_effect("elona.poisoned", 100)
      if gain_resist then
         mod_resist_chance(params.chara, "elona.poison", 6)
      end
   end
end

eating_effect.cobra = eating_effect_poisonous(true)
eating_effect.poisonous = eating_effect_poisonous(false)


function eating_effect.troll(corpse, params)
   eat_message(params.chara, "troll", "Green")
   Skill.gain_skill_exp(params.chara, "core.healing", 200)
end

function eating_effect.rotten_one(corpse, params, result)
   eat_message(params.chara, "rotten_one", "Purple")
   return Hunger.add_rotten_food_exp_losses(params.chara, result.exp_gains)
end

function eating_effect.beetle(corpse, params)
   eat_message(params.chara, "beetle", "Green")
   Skill.gain_skill_exp(params.chara, "elona.stat_strength", 250)
end

function eating_effect.mandrake(corpse, params)
   eat_message(params.chara, "mandrake", "Green")
   Skill.gain_skill_exp(params.chara, "core.meditation", 500)
end

function eating_effect.grudge(corpse, params)
   eat_message(params.chara, "grudge", "Purple")
   params.chara:apply_effect("elona.confused", 200)
end

function eating_effect.calm(corpse, params)
   eat_message(params.chara, "calm", "Green")
   Effect.damage_insanity(params.chara, -20)
end

function eating_effect.fire_crab(corpse, params)
   eating_effect.calm(corpse, params)
   mod_resist_chance(params.chara, "elona.fire", 5)
end

function eating_effect.fire_centipede(corpse, params)
   mod_resist_chance(params.chara, "elona.fire", 5)
end

function eating_effect.yith(corpse, params)
   eat_message(params.chara, "insanity", "Purple")
   Effect.damage_insanity(params.chara, 50)
   mod_resist_chance(params.chara, "elona.mind", 5)
end

function eating_effect.lightning(corpse, params)
   eat_message(params.chara, "lightning", "Purple")
   params.chara:apply_effect("elona.paralyzed", 300)
end

function eating_effect.cat(corpse, params)
   if not params.chara:is_player() then
      return
   end
   eat_message(params.chara, "cat", "None")
   Effect.modify_karma(params.chara, -5)
end

function eating_effect.ether(corpse, params)
   if not params.chara:is_player() then
      return
   end
   eat_message(params.chara, "ether", "Purple")
   Effect.modify_corruption(params.chara, 1000)
end


local function eating_effect_giant(amount)
   return function(corpse, params)
      eat_message(params.chara, "giant", "Green")
      Skill.gain_skill_exp(params.chara, "elona.stat_constitution", amount)
   end
end

eating_effect.cyclops = eating_effect_giant(500)
eating_effect.titan = eating_effect_giant(800)


function eating_effect.imp(corpse, params)
   eat_message(params.chara, "imp", "Green")
   Skill.gain_skill_exp(params.chara, "elona.stat_magic", 500)
end

function eating_effect.hand(corpse, params)
   eat_message(params.chara, "strength", "Green")
   Skill.gain_skill_exp(params.chara, "elona.stat_strength", 400)
end

function eating_effect.mammoth(corpse, params)
   eat_message(params.chara, "strength", "Green")
   -- NOTE: doesn't apply anything?
end


local function eating_effect_ghost(amount)
   return function(corpse, params)
      eat_message(params.chara, "ghost", "Green")
      Skill.gain_skill_exp(params.chara, "elona.stat_will", amount);
   end
end

eating_effect.ghost = eating_effect_ghost(250)
eating_effect.nymph = eating_effect_ghost(400)


function eating_effect.quickling(corpse, params)
   eat_message(params.chara, "quickling", "Green")

   local current = params.chara:skill_level("elona.stat_speed")
   local amount = math.clamp(2500 - current * current / 10, 20, 2500)
   Skill.gain_skill_exp(params.chara, "elona.stat_speed", amount);
end

function eating_effect.alien(corpse, params)
   eat_message(params.chara, "alien", "None")
   Effect.impregnate(params.chara)
end

function eating_effect.fire_ent(corpse, params)
   mod_resist_chance(params.chara, "elona.fire", 3)
end

function eating_effect.ice_ent(corpse, params)
   mod_resist_chance(params.chara, "elona.cold", 3)
end

function eating_effect.electric_cloud(corpse, params)
   mod_resist_chance(params.chara, "elona.lightning", 4)
end

function eating_effect.chaos_cloud(corpse, params)
   eat_message(params.chara, "chaos_cloud", "Purple")
   params.chara:apply_effect("elona.confusion", 300)
   mod_resist_chance(params.chara, "elona.chaos", 5)
end

function eating_effect.floating_eye(corpse, params)
   eating_effect.lightning(corpse, params)
   mod_resist_chance(params.chara, "elona.nerve", 3)
end

function eating_effect.chaos_eye(corpse, params)
   eating_effect.lightning(corpse, params)
   mod_resist_chance(params.chara, "elona.chaos", 3)
end

function eating_effect.mad_gaze(corpse, params)
   eating_effect.lightning(corpse, params)
   mod_resist_chance(params.chara, "elona.mind", 3)
end


local function eating_effect_pumpkin(resist_gain_chance)
   return function(corpse, params)
      mod_resist_chance(params.chara, "elona.mind", resist_gain_chance)
   end
end

eating_effect.pumpkin = eating_effect_pumpkin(10)
eating_effect.greater_pumpkin = eating_effect_pumpkin(8)
eating_effect.halloween_nightmare = eating_effect_pumpkin(6)


function eating_effect.stalker(corpse, params)
   mod_resist_chance(params.chara, "elona.darkness", 4)
end


return eating_effect
