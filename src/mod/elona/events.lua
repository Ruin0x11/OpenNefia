local I18N = require("api.I18N")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local NpcMemory = require("mod.elona_sys.api.NpcMemory")
local Skill = require("mod.elona_sys.api.Skill")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Rand = require("api.Rand")
local World = require("api.World")
local Resolver = require("api.Resolver")
local ElonaAction = require("mod.elona.api.ElonaAction")
local MapObject = require("api.MapObject")
local Text = require("mod.elona.api.Text")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Magic = require("mod.elona_sys.api.Magic")
local Input = require("api.Input")
local Log = require("api.Log")

--
--
-- damage_hp events
--
--

local function retreat_in_fear(chara, params)
   -- >>>>>>>> shade2/chara_func.hsp:1535 		if cHp(tc)<cMhp(tc)/5:if tc!pc:if cFear(tc)=0:if ..
   if chara.hp < chara:calc("max_hp") / 5 then
      if chara:is_player() or chara:has_effect("elona.fear") then
         return
      end

      if chara:is_immune_to_effect("elona.fear") then
         return
      end

      local retreats = (params.damage * 100 / chara:calc("max_hp") + 10) > Rand.rnd(200)

      if params.attacker and params.attacker:has_trait("elona.no_fear") then
         retreats = false
      end

      if retreats then
         assert(chara:set_effect_turns("elona.fear", Rand.rnd(20) + 5))
         Gui.mes_c_visible("damage.runs_away_in_terror", chara.x, chara.y, "Blue", chara)
      end
   end
   -- <<<<<<<< shade2/chara_func.hsp:1539 			} ..
end

Event.register("base.on_damage_chara",
               "Retreat in fear", retreat_in_fear)

local function disturb_sleep(chara, params)
   if not params.element or not params.element.preserves_sleep then
      if chara:has_effect("elona.sleep") then
         chara:remove_effect("elona.sleep")
         Gui.mes("sleep is disturbed " .. chara.uid)
      end
   end
end

Event.register("base.on_damage_chara",
               "Disturb sleep", disturb_sleep)

local function explodes(chara)
   if chara:calc("is_explodable") then
      local chance = chara:calc("explode_chance") or Rand.one_in_percent(3)
      if Rand.percent_chance(chance) then
         chara.is_about_to_explode = true
         Gui.mes_c("damage.explode_click", "LightBlue")
      end
   end
end

Event.register("base.on_damage_chara",
               "Explodes behavior", explodes)

local function splits(chara, params)
   if chara:calc("splits") then
      local threshold = chara:calc("split_threshold") or 20
      local chance = chara:calc("split_chance") or Rand.one_in_percent(10)
      if params.damage > chara:calc("max_hp") / threshold or Rand.percent_chance(chance) then
         if not Map.is_world_map() then
            if chara:clone() then
               Gui.mes(chara.uid .. " splits.")
            end
         end
      end
   end
end

-- TODO: only triggers depending on damage events flag
Event.register("base.on_damage_chara",
               "Split behavior", splits)

local split2_effects = {
   "elona.confusion",
   "elona.dimming",
   "elona.poison",
   "elona.paralysis",
   "elona.blindness",
}

local function splits2(chara, params)
   if chara:calc("splits2") then
      local chance = chara:calc("split2_chance") or Rand.one_in_percent(3)
      if Rand.percent_chance(chance) then
         if not fun.iter(split2_effects)
            :any(function(e) return chara:has_effect(e) end)
         then
            if not Map.is_world_map() then
               if chara:clone() then
                  Gui.mes(chara.uid .. " splits.")
               end
            end
         end
      end
   end
end

Event.register("base.on_damage_chara",
               "Split behavior (2)", splits2)

local function is_quick_tempered(chara, params)
   if chara:calc("is_quick_tempered") then
      if not chara:has_effect("elona.fury") then
         if Rand.one_in(20) then
            Gui.mes_visible(chara.uid .. " engulfed in fury", chara.x, chara.y, "Blue")
            chara:set_effect_turns("elona.fury", Rand.rnd(30) + 15)
         end
      end
   end
end

Event.register("base.on_damage_chara",
               "Quick tempered", is_quick_tempered)

local function play_heartbeat(chara)
   if chara:is_player() then
      local threshold = 25 * 0.01
      if chara.hp < chara:calc("max_hp") * threshold then
         Gui.play_sound("base.heart1")
      end
   end
end

Event.register("base.on_damage_chara",
               "Play heartbeat sound", play_heartbeat)

local function proc_lay_hand(chara)
   if chara.hp < 0 then
      for _, ally in chara:iter_party() do
         if Chara.is_alive(ally)
            and chara.uid ~= ally.uid
            and ally:calc("has_lay_hand")
            and ally:calc("is_lay_hand_available")
         then
            ally:reset("is_lay_hand_available", false)
            Gui.mes("Lay hand!")
            Gui.mes(chara.uid .. " is healed.")
            chara:reset("hp", chara.max_hp / 2)
            Gui.play_sound("base.pray2")
            break
         end
      end
   end
end

Event.register("base.after_chara_damaged",
               "Proc lay hand", proc_lay_hand)

local function proc_sandbag(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1499 		if cBit(cSandBag,tc):cHp(tc)=cMhp(tc) ..
   if chara.hp < 0 and chara:calc("is_hung_on_sandbag") then
      chara.hp = chara:calc("max_hp")
   end
   -- <<<<<<<< shade2/chara_func.hsp:1499 		if cBit(cSandBag,tc):cHp(tc)=cMhp(tc) ..
end

Event.register("base.after_chara_damaged",
               "Proc sandbag", proc_sandbag)

local function proc_sandbag_talk(chara, params)
   -- >>>>>>>> shade2/chara_func.hsp:1769 	if cBit(cSandBag,tc):if sync(tc):txt "("+dmg+")"+ ..
   if chara:calc("is_hung_on_sandbag") then
      if chara:is_in_fov() then
         local mes = ("(%d)%s"):format(params.damage, I18N.space())
         Gui.mes(mes)
         if Rand.one_in(20) then
            Gui.mes_c(I18N.quote_speech("damage.sand_bag"), "Talk")
         end
      end
   end
   -- <<<<<<<< shade2/chara_func.hsp:1769 	if cBit(cSandBag,tc):if sync(tc):txt "("+dmg+")"+ ..
end

Event.register("base.after_chara_damaged",
               "Proc sandbag talk", proc_sandbag_talk, {priority = 500000})

local function fix_name_gender_age(chara)
   if chara.proto.has_random_name then
      chara.name = Text.random_name()
   end
end

Event.register("base.on_build_chara", "Fix character name, age, gender", fix_name_gender_age)

local function fix_level_and_quality(chara)
   -- >>>>>>>> shade2/chara.hsp:492 *chara_fix ..
   if chara.quality == Enum.Quality.Great then
      chara.name = I18N.get("chara.quality.great", chara.name)
      chara.level = math.floor(chara.level * 10 / 8)
   end
   if chara.quality == Enum.Quality.God then
      chara.name = I18N.get("chara.quality.god", chara.name)
      chara.level = math.floor(chara.level * 10 / 6)
   end
   -- <<<<<<<< shade2/chara.hsp:503 	return ..
end

Event.register("base.on_build_chara",
               "Fix character level and quality", fix_level_and_quality)

local function calc_initial_resistance_level(chara, element)
   -- >>>>>>>> shade2/calculation.hsp:976 	repeat tailResist-headResist,headResist ..
   if chara:is_player() then
      return 100
   end

   local initial_level = chara:resist_level(element._id)
   local level = math.min(chara:calc("level") * 4 + 96, 300)
   if initial_level ~= 0 then
      if initial_level < 100 or initial_level > 500 then
         level = initial_level
      else
         level = level + initial_level
      end
   end
   if element.calc_initial_resist_level then
      level = element.calc_initial_resist_level(chara, level)
   end
   return level
   -- <<<<<<<< shade2/calculation.hsp:981 	loop ..
end

-- >>>>>>>> shade2/calculation.hsp:983 	i=4 ..
local initial_skills = {
   ["elona.axe"] = 4,
   ["elona.blunt"] = 4,
   ["elona.bow"] = 4,
   ["elona.crossbow"] = 4,
   ["elona.evasion"] = 4,
   ["elona.faith"] = 4,
   ["elona.healing"] = 4,
   ["elona.heavy_armor"] = 4,
   ["elona.light_armor"] = 4,
   ["elona.long_sword"] = 4,
   ["elona.martial_arts"] = 4,
   ["elona.meditation"] = 4,
   ["elona.medium_armor"] = 4,
   ["elona.polearm"] = 4,
   ["elona.scythe"] = 4,
   ["elona.shield"] = 3,
   ["elona.short_sword"] = 4,
   ["elona.stat_luck"] = 50,
   ["elona.stave"] = 4,
   ["elona.stealth"] = 4,
   ["elona.throwing"] = 4
}
-- <<<<<<<< shade2/calculation.hsp:1006 	skillInit rsLUC,r1,50 ...

local function init_skills_from_table(chara, tbl)
   for skill_id, level in pairs(tbl) do
      local init = Skill.calc_initial_skill_level(skill_id, level, chara:base_skill_level(skill_id), chara:calc("level"), chara)
      chara:set_base_skill(skill_id, init.level, init.potential, 0)
   end
end

local function init_skills(chara)
   local elements = data["base.element"]:iter():filter(function(e) return e.can_resist end)
   for _, element in elements:unwrap() do
      local level = calc_initial_resistance_level(chara, element)
      chara:set_base_resist(element._id, level, 0, 0)
   end

   init_skills_from_table(chara, initial_skills)
end

Event.register("base.on_build_chara",
               "Init skills", init_skills)

local function apply_race_class(chara)
   -- TODO: Should not be applied on player
   -- It is actually possible for characters to lack a class, but usually not a race.
   if chara.race ~= nil then
      Skill.apply_race_params(chara, chara.race)
   end
   if chara.class ~= nil then
      Skill.apply_class_params(chara, chara.class)
   end

   local rest = Resolver.resolve(chara, {object = chara, diff_only = true, override_method = true})
   chara:mod_base_with(rest, "set")
end

Event.register("base.on_normal_build",
               "Init race and class", apply_race_class)

local function init_lay_hand(chara)
   if chara.has_lay_hand then
      chara.is_lay_hand_available = true
   end
end

Event.register("base.on_build_chara",
               "Init lay hand", init_lay_hand)

local function init_chara_defaults(chara)
   -- >>>>>>>> shade2/chara.hsp:509 	cInterest(rc)=100 ..
   chara.performance_interest = chara.performance_interest or 0
   chara.performance_interest_revive_date = chara.performance_interest_revive_date or 0
   chara.fov = 14
   -- <<<<<<<< shade2/chara.hsp:511 	cFov(rc)=14 ..

   -- >>>>>>>> shade2/chara.hsp:516 	if rc=pc:cHunger(rc)=9000:else:cHunger(rc)=defAll ..
   if chara:is_player() then
      chara.nutrition = 9000
   else
      chara.nutrition = 5000 + Rand.rnd(4000)
   end

   chara.height = chara.height + Rand.rnd(chara.height / 5 + 1) - Rand.rnd(chara.height / 5 + 1)
   chara.weight = math.floor(chara.height * chara.height * (Rand.rnd(6) + 18) / 10000)

   chara.required_experience = Skill.calc_required_experience(chara)
   -- <<<<<<<< shade2/chara.hsp:521 	call calcExpToNextLevel,(r1=rc) ..

   -- >>>>>>>> shade2/chara.hsp:532 	if rc=pc{ ..
   if chara:is_player() then
      chara.initial_max_cargo_weight = 80000
      chara.max_cargo_weight = chara.initial_max_cargo_weight
   end
   -- <<<<<<<< shade2/chara.hsp:534 		} ..
end

Event.register("base.on_build_chara",
               "Init chara_defaults", init_chara_defaults)

local function init_chara_image(chara)
   if chara.male_image and chara.gender == "male" then
      chara.image = chara.male_image
   end
   if chara.female_image and chara.gender == "female" then
      chara.image = chara.female_image
   end
end

Event.register("base.on_build_chara",
               "Init chara image", init_chara_image)



local function calc_damage_fury(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1441 	dmg = dmgOrg * (1+(cAngry(tc)>0)) ..
   if chara:has_effect("elona.fury") then
      result = result * 2
   end
   if params.attacker and params.attacker:has_effect("elona.fury") then
      result = result * 2
   end
   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1442 	if dmgSource>=0 : if cAngry(dmgSource)>0:dmg*=2 ..
end

Event.register("base.hook_calc_damage",
               "Proc fury", calc_damage_fury)


local function calc_damage_resistance(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1444 	if (ele=false)or(ele>=tailResist){ ..
   local element = params.element
   if element and element.can_resist then
      local resistance = math.floor(chara:resist_level(element._id) / 50)
      if resistance < 3 then
         result = result * 150 / math.clamp(resistance * 50 + 50, 40, 150)
      elseif resistance < 10 then
         result = result * 100 / (resistance * 50 + 50)
      else
         result = 0
      end
      result = result * 100 / (chara:resist_level("elona.magic") / 2 + 50)
   end
   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1454 		} ..
end

Event.register("base.hook_calc_damage",
               "Proc elemental resistance", calc_damage_resistance)

local function calc_element_damage(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1458 	if cWet(tc)>0{ ..
   local element = params.element
   if element and element.on_modify_damage then
      result = element.on_modify_damage(chara, result)
   end
   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1461 		} ..
end

Event.register("base.hook_calc_damage",
               "Proc elemental damage", calc_element_damage)

local function is_immune_to_elemental_damage(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1463 	if ele:if ele!rsResMagic:if cBit(cResEle,tc):dmg= ..
   if chara:calc("is_immune_to_elemental_damage") then
      if params.element and params.element._id ~= "elona.magic" then
         result = 0
      end
   end
   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1463 	if ele:if ele!rsResMagic:if cBit(cResEle,tc):dmg= ..
end

Event.register("base.hook_calc_damage",
               "Proc elemental damage immunity", is_immune_to_elemental_damage)

local function is_metal_damage(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1464 	if cBit(cMetal,tc):dmg=rnd(dmg/10+2) ..
   if chara:calc("is_metal") then
      result = Rand.rnd(result / 10 + 2)
   end
   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1464 	if cBit(cMetal,tc):dmg=rnd(dmg/10+2) ..
end

Event.register("base.hook_calc_damage",
               "Proc is_metal damage", is_metal_damage)

local function proc_contingency(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1465 	if cBit(cContingency,tc):if cHp(tc)-dmg<=0:if cal ..
   if chara.hp - result <= 0 then
      local buff = chara:find_buff("elona.contingency")
      if buff and buff.power >= Rand.rnd(100) then
         result = -result
      end
   end

   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1465 	if cBit(cContingency,tc):if cHp(tc)-dmg<=0:if cal ..
end

Event.register("base.hook_calc_damage",
               "Proc contingency", proc_contingency)

local function proc_damage_immunity(chara, params, result)
   -- >>>>>>>> elona122/shade2/chara_func.hsp:1466 	if cImmuneDamage(tc)>0:if cImmuneDamage(tc)>rnd(1 ..
   local chance = chara:calc("damage_immunity_rate") or 0
   if chance > 0 and chance > Rand.one_in(100) then
      result = 0
   end
   return result
   -- <<<<<<<< elona122/shade2/chara_func.hsp:1466 	if cImmuneDamage(tc)>0:if cImmuneDamage(tc)>rnd(1 ..
end

Event.register("base.hook_calc_damage",
               "Proc damage immunity", proc_damage_immunity)

local function calc_kill_exp(victim, params)
   local level = victim:calc("level")
   local result = math.clamp(level, 1, 200) * math.clamp(level + 1, 1, 200) * math.clamp(level + 2, 1, 200) / 20 + 8
   if level > params.attacker:calc("level") then
      result = result / 4
   end
   if victim:calc("splits") or victim:calc("splits2") then
      result = result / 20
   end
   return result
end

Event.register("base.on_calc_kill_exp",
               "Kill experience formula", calc_kill_exp)

Event.register(
   "base.hook_generate_chara",
   "Shade generation",
   function(_, params, result)
      -- >>>>>>>> shade2/chara.hsp:473 	npcMemory(1,dbId)++ 	 ..
      if params.id ~= "elona.shade" then
         return result
      end

      if not Rand.one_in(5) then
         return result
      end

      params.level = params.level * 2
      if params.quality > Enum.Quality.Good then
         params.quality = Enum.Quality.Good
      end
      local Charagen = require("mod.tools.api.Charagen")
      params.id = Charagen.random_chara_id_raw(params.level, params.filter, params.category)

      -- using Chara.create would cause recursion
      local chara = MapObject.generate_from("base.chara", params.id)

      chara.is_shade = true
      chara.title = "shade"
      chara.image = "elona.chara_shade"
      -- <<<<<<<< shade2/chara.hsp:485 	if cmShade:cnName(rc)=lang("シェイド","shade"):	cPic( ...

      chara = MapObject.build(chara, params.gen_params)

      return chara
end)

Event.register("base.generate_chara_name", "Elona character name generation", function(_, _, result)
                  if result and result ~= "" then
                     return result
                  end
                  return Text.random_name()
end)

Event.register("base.generate_title", "Elona title generation", function(_, params, result)
                  if result and result ~= "" then
                     return result
                  end
                  return Text.random_title(params.kind, params.seed or nil)
end)

Event.register("base.on_chara_generated", "npc memory", function(chara) NpcMemory.on_generated(chara._id) end)
Event.register("base.on_object_cloned", "npc memory",
               function(_, params)
                  if params.object._type == "base.chara" then
                     NpcMemory.on_generated(params.object._id)
                  end
               end)
Event.register("base.on_kill_chara", "npc memory",
               function(victim, params)
                  -- >>>>>>>> shade2/chara_func.hsp:1685 		if tc=pc : gDeath++	 ..
                  if victim:is_player() then
                     save.base.total_deaths = save.base.total_deaths + 1
                  end
                  -- <<<<<<<< shade2/chara_func.hsp:1685 		if tc=pc : gDeath++	 ..
                  -- >>>>>>>> shade2/chara_func.hsp:1726 		if tc!pc{ ..
                  if not victim:is_player() then
                     NpcMemory.on_killed(victim._id)
                     -- TODO custom talk
                     if victim:is_allied() then
                        Gui.mes("damage.you_feel_sad")
                     end
                  end
                  Effect.on_kill(params.source, victim)
                  -- TODO riding
                  -- TODO crowd
                  -- <<<<<<<< shade2/chara_func.hsp:1735 		check_kill dmgSource,tc ..
               end)
Event.register("base.on_map_leave", "npc memory",
               function(map)
                  if map.is_temporary then
                     for _, v in map:iter_charas() do
                        if Chara.is_alive(v) then
                           print( "forget " .. v._id)
                           NpcMemory.forget_generated(v._id)
                        end
                     end
                  end
               end)


---
--- Dialog
---

local function bump_into_chara(player, params, result)
   local on_cell = params.chara
   local reaction = on_cell:reaction_towards(player)

   if reaction > 0 and not on_cell:calc("is_hung_on_sandbag") then
      if on_cell:is_ally() or on_cell.faction == "base.citizen" or Gui.player_is_running() then
         if player:swap_places(on_cell) then
            Gui.mes("action.move.displace.text", on_cell)
            Gui.set_scroll()
            on_cell:emit("elona.on_displaced")
         end
         return "turn_end"
      end

      Dialog.talk_to_chara(on_cell)
      return "player_turn_query"
   end

   -- TODO: relation as -1
   if reaction <= 0 then
      player:set_target(on_cell)
      ElonaAction.melee_attack(player, on_cell)
      Gui.set_scroll()
      return "turn_end"
   end

   return result
end

Event.register("elona_sys.on_player_bumped_into_chara",
               "Attack/swap position", bump_into_chara)


local function calc_dialog_choices(speaker, params, result)
   table.insert(result, {"talk", "talk.npc.common.choices.talk"})

   if speaker.roles then
      for id, _ in pairs(speaker.roles) do
         local role_data = data["elona.role"]:ensure(id)
         if role_data.dialog_choices then
            for _, choice in ipairs(role_data.dialog_choices) do
               if type(choice) == "function" then
                  local choices = choice(speaker, params)
                  assert(type(choices) == "table")
                  for _, choice in ipairs(choices) do
                     table.insert(result, choice)
                  end
               else
                  table.insert(result, choice)
               end
            end
         end
      end
   end

   return result
end

Event.register("elona.calc_dialog_choices", "Default NPC dialog choices", calc_dialog_choices)


local function refresh_hp_mp_stamina(chara, params, result)
   local mp_factor = chara:skill_level("elona.stat_magic") * 2
      + chara:skill_level("elona.stat_will")
      + (chara:skill_level("elona.stat_learning") / 3)
      * (chara:calc("level") / 25)
      + chara:skill_level("elona.stat_magic")

   chara.max_mp = math.floor(math.clamp(mp_factor, 1, 1000000) * (chara:skill_level("elona.stat_mana") / 100))

   local hp_factor = chara:skill_level("elona.stat_constitution") * 2
      + chara:skill_level("elona.stat_strength")
      + (chara:skill_level("elona.stat_will") / 3)
      * (chara:calc("level") / 25)
      + chara:skill_level("elona.stat_strength")

   chara.max_hp = math.floor(math.clamp(hp_factor, 1, 1000000) * (chara:skill_level("elona.stat_life") / 100)) + 5

   chara.max_stamina = math.floor(100 + (chara:skill_level("elona.stat_constitution") + chara:skill_level("elona.stat_strength")) / 5
                                     + chara:trait_level("elona.stamina") * 8)
end

Event.register("base.on_refresh", "Update max HP/MP/stamina", refresh_hp_mp_stamina)

local function apply_buff_effects(chara, params, result)
   for _, buff in ipairs(chara.buffs) do
      if buff.duration > 0 then
         local buff_data = data["elona_sys.buff"]:ensure(buff._id)
         if buff_data.on_refresh then
            buff_data.on_refresh(buff, chara)
         end
      end
   end
end

Event.register("base.on_refresh", "Apply buff effects", apply_buff_effects)

local footstep = 0
local footsteps = {"base.foot1a", "base.foot1b"}
local snow_footsteps = {"base.foot2a", "base.foot2b", "base.foot2c"}
Event.register("elona_sys.hook_player_move", "Leave footsteps",
               function(_, params, result)
                  local player = params.chara
                  local map = player:current_map()
                  if (player.x ~= result.pos.x or player.y ~= result.pos.y)
                     and Map.can_access(result.pos.x, result.pos.y, map)
                  then
                     local tile = map:tile(params.chara.x, params.chara.y)
                     if tile.kind == Enum.TileRole.Snow then
                        Gui.play_sound(snow_footsteps[footstep%2+1])
                        footstep = footstep + Rand.rnd(2)
                     else
                        if map:has_type("world_map") then
                           Gui.play_sound(footsteps[footstep%2+1])
                           footstep = footstep + 1
                        end
                     end
                  end

                  return result
               end)

local function respawn_mobs()
   if save.base.play_turns % 20 == 0 then
      local Calc = require("mod.elona.api.Calc")
      -- TODO
      -- Calc.respawn_mobs()
   end
end

Event.register("base.on_minute_passed", "Respawn mobs", respawn_mobs)

local function on_regenerate(chara)
   if Rand.one_in(6) then
      local amount = Rand.rnd(chara:skill_level("elona.healing") / 3 + 1) + 1
      chara:heal_hp(amount, true)
   end
   if Rand.one_in(5) then
      local amount = Rand.rnd(chara:skill_level("elona.meditation") / 2 + 1) + 1
      chara:heal_mp(amount, true)
   end
end

Event.register("base.on_regenerate", "Regenerate HP/MP", on_regenerate)

local function gain_healing_meditation_exp(chara)
   local exp = 0
   if chara.hp ~= chara:calc("max_hp") then
      local healing = chara:skill_level("elona.healing")
      if healing < chara:skill_level("elona.stat_constitution") then
         exp = 5 + healing / 5
      end
   end
   Skill.gain_skill_exp(chara, "elona.healing", exp, 1000)

   exp = 0
   if chara.mp ~= chara:calc("max_mp") then
      local meditation = chara:skill_level("elona.meditation")
      if meditation < chara:skill_level("elona.stat_magic") then
         exp = 5 + meditation / 5
      end
   end
   Skill.gain_skill_exp(chara, "elona.meditation", exp, 1000)
end

local function gain_stealth_experience(chara)
   local exp = 2

   local map = chara:current_map()
   if map and map:has_type("world_map") and Rand.one_in(20) then
      exp = 0
   end

   Skill.gain_skill_exp(chara, "elona.stealth", exp, 0, 1000)
end

local function gain_weight_lifting_experience(chara)
   local exp = 0

   if chara:calc("inventory_weight_type") > 0 then
      exp = 4

      local map = chara:current_map()
      if map and map:has_type("world_map") and Rand.one_in(20) then
         exp = 0
      end
   end

   Skill.gain_skill_exp(chara, "elona.weight_lifting", exp, 0, 1000)
end

local function update_emotion_icon(chara)
   chara.emotion_icon_turns = math.max(chara.emotion_icon_turns - 1, 0)
   if chara.emotion_icon and chara.emotion_icon_turns == 0 then
      chara.emotion_icon = nil
   end
end

Event.register("base.before_chara_turn_start", "Update emotion icon", update_emotion_icon)

local function proc_enough_exp_for_level(chara)
   while chara.experience >= chara.required_experience do
      if chara:is_player() then
         Gui.play_sound("base.ding1")
         Gui.mes_alert()
      end
      Skill.gain_level(chara, true)
   end
end

Event.register("base.before_chara_turn_start", "Check if character leveled up", proc_enough_exp_for_level, {priority = 90000})

local function gain_experience_at_turn_start(chara)
   if not chara:is_player() then
      return
   end

   local turn = chara.turns_alive % 10
   if turn == 1 then
      Chara.iter_party()
         :filter(Chara.is_alive)
         :each(gain_healing_meditation_exp)
   elseif turn == 2 then
      gain_stealth_experience(chara)
   elseif turn == 3 then
      gain_weight_lifting_experience(chara)
   elseif turn == 4 then
      if not chara:has_activity() then
         chara:heal_stamina(2, true)
      end
   end
end

Event.register("base.before_chara_turn_start", "Gain experience", gain_experience_at_turn_start)

local function proc_return(chara)
   if not chara:is_player() then
      return
   end

   local s = save.elona
   if s.turns_until_cast_return > 0 then
      s.turns_until_cast_return = s.turns_until_cast_return - 1

      local map = chara:current_map()
      if not map then
         s.turns_until_cast_return = 0
      end
      if map:calc("prevents_return") then
         Gui.mes("magic.return.prevented.normal")
         s.turns_until_cast_return = 0
         return
      end

      if s.turns_until_cast_return <= 0 and not DeferredEvent.is_pending() then
         local has_escort = Chara.iter_allies()
            :filter(Chara.is_alive)
            :extract("is_quest_escort")
            :any()

         if has_escort then
            Gui.mes("magic.return.prevented.normal")
            return
         end

         if chara:calc("inventory_weight_type") >= 4 then
            Gui.mes("magic.return.prevented.overweight")
            return
         end

         local dest = s.return_destination_map_uid
         if dest == nil or dest == map.uid then
            Gui.mes("common.nothing_happens")
            return
         end

         local blocked = Event.trigger("elona.before_cast_return", {}, false)
         if blocked then
            return
         end

         Gui.play_sound("base.teleport1")
         Gui.mes("magic.return.door_opens")
         Gui.update_screen()
         Input.query_more()
         local map_uid = s.return_destination_map_uid
         s.return_destination_map_uid = nil

         local _, new_map = assert(Map.load(map_uid))
         Map.travel_to(new_map)
      end
   end
end

Event.register("base.before_chara_turn_start", "Proc return event", proc_return)

local function init_save()
   local s = save.elona
   s.turns_until_cast_return = 0
   s.return_destination_map_uid = nil
   s.holy_well_count = 0
   s.guild = nil
   s.artifact_locations = {}
   s.inheritable_item_count = 0
   s.fire_giant_uid = nil
   s.home_rank = "elona.cave"
   s.flag_has_met_ally = false
   s.total_skills_learned = 0
end

Event.register("base.on_init_save", "Init save (Elona)", init_save)

local function decrease_nutrition(chara, params, result)
   if not chara:is_player() then
      return result -- TODO nil counts as no modifying result
   end

   local nutrition = chara:calc("nutrition")
   if nutrition < 2000 then
      if nutrition < 1000 then
         chara:damage_hp(Rand.rnd(2) + chara:calc("max_hp") / 50, "elona.hunger")
         if save.elona_sys.awake_hours % 10 == 0 then
            -- interrupt action
            if Rand.one_in(50) then
               Effect.modify_weight(chara, -1)
            end
         end
      end
      result.regeneration = false
   end

   return result
end

Event.register("base.on_chara_turn_end",
               "Decrease nutrition",
               decrease_nutrition)

local function play_default_map_music(map, _, music_id)
   if map:has_type("field") then
      return "none"
   end
   if map:has_type("town") then
      music_id = "elona.town1"
   end
   if map:has_type("player_owned") then
      music_id = "elona.home"
   end
   if map:calc("music") then
      music_id = map:calc("music")
   end
   if map:has_type("dungeon") then
      local choices = {
         "elona.dungeon1",
         "elona.dungeon2",
         "elona.dungeon3",
         "elona.dungeon4",
         "elona.dungeon5",
         "elona.dungeon6"
      }
      local hour = World.date().hour
      music_id = choices[hour % 6 + 1]
   end

   if music_id == nil or map:has_type("world_map") then
      local choices = {
         "elona.field1",
         "elona.field2",
         "elona.field3",
      }
      local day = World.date().day
      music_id = choices[day % 3 + 1]
   end

   return music_id
end

Event.register("elona_sys.calc_map_music", "Play default map music",
               play_default_map_music)

local function calc_wand_success(chara, params)
   -- >>>>>>>> shade2/proc.hsp:1511 	if (efId>=headSpell)&(efId<tailSpell){ ..
   local skill_data = Magic.skills_for_magic(params.magic_id)[1] or nil

   local item = params.item

   if not chara:is_player() or item:calc("is_zap_always_successful") then
      return true
   end

   local magic_device = chara:skill_level("elona.magic_device")

   local success
   if skill_data and skill_data.type == "spell" then
      success = false

      local skill = magic_device * 20 + 100
      if item:calc("curse_state") == "blessed" then
         skill = skill * 125 / 100
      end
      if Effect.is_cursed(item:calc("curse_state")) then
         skill = skill * 50 / 100
      elseif Rand.one_in(2) then
         success = true
      end
      if Rand.rnd(skill_data.difficulty + 1) / 2 <= skill then
         success = true
      end
   else
      success = true
   end

   if Rand.one_in(30) then
      success = false
   end

   return success
   -- <<<<<<<< shade2/proc.hsp:1521 	if rnd(30)=0:f=false ..
end
Event.register("elona.calc_wand_success", "Default", calc_wand_success)

local function calc_exp_modifier(target)
   -- >>>>>>>> shade2/action.hsp:1251 	expModifer=1+cBit(cSandBag,tc)*15+cBit(cSplit,tc) ..
   local map = target:current_map()
   return 1 + ((target:calc("is_hung_on_sandbag") and 15) or 0)
      + ((target:calc("splits") and 1) or 0)
      + ((target:calc("splits2") and 1) or 0)
      + (map:calc("exp_modifier") or 0)
   -- <<<<<<<< shade2/action.hsp:1251 	expModifer=1+cBit(cSandBag,tc)*15+cBit(cSplit,tc) ..
end

local function proc_on_physical_attack_miss(chara, params)
   -- >>>>>>>> shade2/action.hsp:1356 		if (sdata(attackSkill,cc)>sEvade(tc))or(rnd(5)=0 ..
   local exp_modifier = calc_exp_modifier(params.target)
   local attack_skill = chara:skill_level(params.attack_skill)
   local target_evasion = params.target:skill_level("elona.evasion")
   if attack_skill > target_evasion or Rand.one_in(5) then
      local exp = math.clamp(attack_skill - target_evasion / 2 + 1, 1, 20) / exp_modifier
      Skill.gain_skill_exp(params.target, "elona.evasion", exp, 0, 4)
      Skill.gain_skill_exp(params.target, "elona.greater_evasion", exp, 0, 4)
   end
   -- <<<<<<<< shade2/action.hsp:1360 			} ..
end
Event.register("elona.on_physical_attack_miss", "Gain evasion experience", proc_on_physical_attack_miss, 100000)

local function proc_on_physical_attack(chara, params)
   -- >>>>>>>> elona122/shade2/action.hsp:1295 		if critical : skillExp rsCritical,cc,60/expModif ..
   local exp_modifier = calc_exp_modifier(params.target)
   local base_damage = params.base_damage
   local attack_skill = params.attack_skill

   if params.hit == "critical" then
      Skill.gain_skill_exp(chara, "elona.eye_of_mind", 60 / exp_modifier, 2)
   end

   if base_damage > chara:calc("max_hp") / 20
      or base_damage > chara:skill_level("elona.healing")
      or Rand.one_in(5)
   then
      local attack_skill_exp = math.clamp(chara:skill_level("elona.evasion") * 2 - chara:skill_level(attack_skill) + 1, 5, 50) / exp_modifier
      Skill.gain_skill_exp(chara, attack_skill, attack_skill_exp, 0, 4)

      if not params.is_ranged then
         Skill.gain_skill_exp(chara, "elona.tactics", 20 / exp_modifier, 0, 4)
         if chara:calc("is_wielding_two_handed") then
            Skill.gain_skill_exp(chara, "elona.two_hand", 20 / exp_modifier, 0, 4)
         end
         if chara:calc("is_dual_wielding") then
            Skill.gain_skill_exp(chara, "elona.dual_wield", 20 / exp_modifier, 0, 4)
         end
      elseif attack_skill == "elona.throwing" then
         Skill.gain_skill_exp(chara, "elona.tactics", 10 / exp_modifier, 0, 4)
      else
         Skill.gain_skill_exp(chara, "elona.marksman", 25 / exp_modifier, 0, 4)
      end

      -- TODO mount

      local target = params.target
      if Chara.is_alive(target) then
         local exp = math.clamp(250 * base_damage / target:calc("max_hp") + 1, 3, 100) / exp_modifier
         Skill.gain_skill_exp(target, target:calc("armor_class"), exp, 0, 5)
         if target:calc("is_wielding_shield") then
            Skill.gain_skill_exp(target, "elona.shield", 40 / exp_modifier, 0, 4)
         end
      end
   end

   -- <<<<<<<< elona122/shade2/action.hsp:1312 		} ..
end
Event.register("elona.on_physical_attack_hit", "Gain skill experience", proc_on_physical_attack, 100000)

local function proc_weapon_enchantments(chara, params)
   local weapon = params.weapon
   if params.weapon then
      -- >>>>>>>> elona122/shade2/action.hsp:1395 *act_attackSub ..
      for _, enc in weapon:iter_enchantments() do
         enc:on_attack_hit(chara, params)
      end
      -- <<<<<<<< elona122/shade2/action.hsp:1479 	return ..
   end

   -- >>>>>>>> elona122/shade2/calculation.hsp:325 		if ammoProc=encAmmoVopal : pierce=60 		:if sync( ..
   if params.ammo_enchantment then
      local ammo_enc_data = data["base.ammo_enchantment"]:ensure(params.ammo_enchantment)
      if ammo_enc_data.on_attack_hit then
         ammo_enc_data.on_attack_hit(chara, params)
      end
   end
   -- <<<<<<<< elona122/shade2/calculation.hsp:328 		if ammoProc=encAmmoMagic : damage/=10 ..
end
Event.register("elona.on_physical_attack_hit", "Proc weapon enchantments", proc_weapon_enchantments, 200000)

local function proc_damage_reflection(chara, params)
   local damage_reflection = params.target:calc("damage_reflection")
   if damage_reflection > 0 and not params.is_ranged then
      chara:damage_hp(params.damage * damage_reflection / 100 + 1, params.target, { element = "elona.cut", element_power = 100 })
   end
end
Event.register("elona.on_physical_attack_hit", "Proc damage reflection", proc_damage_reflection, 300000)

local function proc_damage_reaction(chara, params)
   -- >>>>>>>> elona122/shade2/action.hsp:1323         if cBarrier(tc)!0{ ..
   local damage_reaction = params.target:calc("damage_reaction")
   if damage_reaction then
      local damage_reaction_data = data["base.damage_reaction"]:ensure(damage_reaction.id)
      local power = damage_reaction.power
      if damage_reaction_data.on_damage then
         damage_reaction_data.on_damage(chara, power, params)
      end
   end
   -- <<<<<<<< elona122/shade2/action.hsp:1352         } ..
end
Event.register("elona.on_physical_attack_hit", "Proc damage reaction", proc_damage_reaction, 400000)
