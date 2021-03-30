local Enum = require("api.Enum")
local Fs = require("api.Fs")
local Util = require("mod.cdata_tools.api.Util")
local Compat = require("mod.elona_sys.api.Compat")
local Filters = require("mod.elona.api.Filters")

local CustomFileParser = require("mod.cdata_tools.api.custom_file.CustomFileParser")
local CustomFileDecoder = require("mod.cdata_tools.api.custom_file.CustomFileDecoder")
local ArchiveUnpacker = require("mod.cdata_tools.api.archive.ArchiveUnpacker")

local CustomNpcDecoder = {}

local AI_ACTIONS = {
   [-9999] = { id = "elona.throw_potion", id_set = Filters.isetthrowpotionminor },
   [-9998] = { id = "elona.throw_potion", id_set = Filters.isetthrowpotionmajor },
   [-9997] = { id = "elona.throw_potion", id_set = Filters.isetthrowpotiongreater },
   [-9996] = { id = "elona.throw_potion", item_id = "elona.bottle_of_salt" },
   [-1] = { id = "elona.melee" },
   [-2] = { id = "elona.ranged" },
   [-3] = { id = "elona.wait_melee" },
   [-4] = { id = "elona.random_movement" },
}

local AI_CALM_ACTIONS = {
   [0] = nil,
   [1] = "elona.calm_roam",
   [2] = "elona.calm_dull",
   [3] = "elona.calm_stand",
   [4] = "elona.calm_follow",
   [5] = "elona.calm_special",
}

local function convert_ai_actions(aiActs)
   local map = function(id)
      id = tonumber(id)
      assert(id)
      local skill_id = Compat.convert_122_id("base.skill", id)
      if skill_id then
         local skill_proto = data["base.skill"]:ensure(skill_id)
         if skill_proto.type == "action" or skill_proto.type == "spell" then
            return { id = "elona.skill", skill_id = skill_id }
         else
            error("unknown ai action skill type " .. skill_proto.type)
         end
      end
      local ai_act = assert(AI_ACTIONS[id])
      return table.deepcopy(ai_act)
   end
   return fun.iter(string.split(aiActs, ",")):map(map):to_list()
end

local function extract_skills(acts)
   return fun.iter(acts):filter(function(act) return act.id == "elona.skill" end):extract("skill_id"):to_list()
end

local function conv_ai_acts(kind)
   return function(result, aiAct)
      local acts = convert_ai_actions(aiAct)
      local skills = extract_skills(acts)

      result.ai_actions = result.ai_actions or {}
      result.ai_actions[kind] = acts
      result.skills = result.skills or {}
      for _, skill in ipairs(skills) do
         if not table.index_of(result.skills, skill) then
            table.insert(result.skills, skill)
         end
      end
   end
end

local function bit_resist(effect)
   data["base.effect"]:ensure(effect)
   return function(result)
      result.effect_immunities = result.effect_immunities or {}
      table.insert(result.effect_immunities, effect)
   end
end

local CBITS = {
   [5] = "is_floating", -- cFloat
   [6] = "is_invisible", -- cInvisi
   [7] = "can_see_invisible", -- cSeeInvisi
   [8] = bit_resist("elona.confusion"), -- cResConfuse
   [9] = bit_resist("elona.blindness"), -- cResBlind
   [10] = bit_resist("elona.fear"), -- cResFear
   [11] = bit_resist("elona.sleep"), -- cResSleep
   [12] = bit_resist("elona.paralysis"), -- cResParalyze
   [13] = bit_resist("elona.poison"), -- cResPoison
   [14] = "is_protected_from_rotten_food", -- cEater
   [15] = "is_protected_from_theft", -- cResSteal
   [16] = "is_incognito", -- cIncognito
   [17] = "always_drops_gold", -- cDropGold
   [18] = "is_about_to_explode", -- cSuicide
   [19] = "is_death_master", -- cDeathMaster
   [20] = "can_cast_rapid_magic", -- cRapidMagic
   [21] = "has_lay_hand", -- cLayHand
   [22] = "is_suitable_for_mount", -- cHorse
   [23] = "splits", -- cSplit
   [24] = "has_cursed_enchantment", -- cEncCurse
   [25] = "is_unsuitable_for_mount", -- cNoHorse
   [26] = "is_immune_to_elemental_damage", -- cResEle
   [27] = "splits2", -- cSplit2
   [28] = "is_metal", -- cMetal
   [29] = "cures_bleeding_quickly", -- cCureBleeding
   [30] = "has_shield_bash", -- cPowerBash
   [31] = "is_immune_to_mines", -- cImmuneMine
   [32] = "is_quick_tempered", -- cTemper
}

local function conv_cbits(result, bitOn)
   local each = function(bit)
      bit = tonumber(bit)
      assert(bit)
      local conv = assert(CBITS[bit], "unknown bit " .. tostring(bit))
      if type(conv) == "string" then
         result[conv] = true -- boolean flag
      elseif type(conv) == "function" then
         conv(result)
      else
         error(conv)
      end
   end
   fun.iter(string.split(bitOn, ",")):each(each)
end

local chara_spec = {
   aiAct = conv_ai_acts("main"),
   aiActSub = conv_ai_acts("sub"),
   aiActSubFreq = { to = "ai_sub_action_chance" },
   aiCalm = {
      to = "ai_calm",
      cb = function(aiCalm) return assert(AI_CALM_ACTIONS[aiCalm]) end
   },
   aiDist = { to = "ai_distance" },
   aiHeal = function(result, aiHeal)
      result.ai_actions = result.ai_actions or {}
      result.ai_actions.low_health_action = {
         id = "elona.skill", skill_id = assert(Compat.convert_122_id("base.skill", tonumber(aiHeal)))
      }
   end,
   aiMove = { to = "ai_move_chance" },
   author = { to = "custom_author", type = "string" },
   bitOn = conv_cbits,
   class = {
      to = "class",
      cb = function(class)
         local class_id = ("elona.%s"):format(class)
         data["base.class"]:ensure(class_id)
         return class_id
      end
   },
   filter = {
      to = "tags",
      type = "string",
      cb = function(filter)
         return fun.iter(string.split(filter, "/")):filter(function(s) return s ~= "" end):to_list()
      end
   },
   fixFaith = { to = "god", type = "string", cb = function(fixFaith, mod) return ("%s.%s"):format(mod, fixFaith) end },
   fixLv = { to = "quality", type = Enum.Quality },
   level = { to = "level" },
   meleeElem = function(result, meleeElem)
      local spl = string.split(meleeElem, ",")
      local element_elona_id = tonumber(spl[1])
      local element_power = tonumber(spl[2])
      result.unarmed_element_id = assert(Compat.convert_122_id("base.element", element_elona_id))
      result.unarmed_element_power = element_power
   end,
   race = {
      to = "race",
      type = "string",
      cb = function(race)
         local race_id = ("elona.%s"):format(race)
         data["base.race"]:ensure(race_id)
         return race_id
      end
   },
   rare = { to = "rarity", type = "number" },
   relation = { to = "relation", type = Enum.Relation },
   resist = {
      to = "resistances",
      type = "string",
      cb = function(resist)
         local spl = string.split(resist, ",")
         local resistances = {}
         for i = 1, #spl/2, 2 do
            local element_elona_id = tonumber(spl[i*2-1])
            local resist_grade = tonumber(spl[i*2])
            local id = assert(Compat.convert_122_id("base.element", element_elona_id))
            local power = resist_grade * 50
            resistances[id] = power
         end
         return resistances
      end
   },
   sex = { to = "gender", type = "number", cb = function(sex) return sex == 1 and "female" or "male" end }, -- TODO gender
   spawnType = { to = "__oomsest_spawntype", type = "number" } -- TODO unimplemented
}

local function make_chara_locale_data(item_data, locale, mod_id, chara_id)
   local result = {}

   local is_jp = locale == "jp"

   local name = Util.get_string(item_data, "name")
   if name then
      local split = string.split(name, ",")
      if is_jp then
         result.name = split[2]
      else
         result.name = split[1]
      end
   end

   if is_jp then
      local raceAlias = Util.get_string(item_data, "raceAlias")
      if raceAlias then
         result.race_alias = raceAlias
      end
   end

   -- TODO locale namespace standardization
   return {
      chara = {
         [mod_id] = {
            [chara_id] = result
         }
      }
   }
end

local function find_item_type(elona_item_type)
   local filter = function(t) return t.ordering == elona_item_type end
   local ty = data["base.item_type"]:iter():filter(filter):nth(1)
   if ty == nil then
      error("Could not find Elona item type " .. elona_item_type)
   end
   return ty._id
end

function CustomNpcDecoder.decode(archive, mod_id, chara_id)
   assert(type(mod_id) == "string", "Please provide a mod ID.")

   -- npc1.t: ignored
   -- local ignored = result["npc1.t"]

   -- npc2.t: BMP format image
   local chara_bmp = archive["npc2.t"]

   -- npc3.t: Custom NPC data, as plain text
   local chara_data = archive["npc3.t"]

   chara_data = CustomFileParser.parse(chara_data)
   chara_data = CustomFileDecoder.decode(chara_data)

   if chara_id == nil then
      local name = Util.get_string(chara_data, "name")
      if name then
         local split = string.split(name, ",")
         if Util.is_ascii_only(split[1]) then
            chara_id = split[1]:gsub(" ", "_")
         end
      end
   end

   chara_id = chara_id or "$chara_id$"

   local chip_result = {
      _bmp = chara_bmp,
      proto = {
         _type = "base.chip",
         _id = ("chara_%s"):format(chara_id)
      },
      requires = {}
   }

   -- apply_spec(chip_result, chip_spec, chara_data)

   local proto = {
      _type = "base.chara",
      _id = chara_id,
     
      image = ("%s.%s"):format(mod_id, chip_result.proto._id)
   }

   local requires = Util.apply_spec(proto, chara_spec, chara_data, mod_id)
   local result = {
      proto = proto,
      requires = requires
   }

   local txt = chara_data.txt
   print("TODO custom talk")

   local locale_data = {
      jp = make_chara_locale_data(chara_data, "jp", mod_id, chara_id),
      en = make_chara_locale_data(chara_data, "en", mod_id, chara_id),
   }

   return {
      chip = chip_result,
      data = result,
      locale_data = locale_data,
      requires = requires
   }
end

function CustomNpcDecoder.decode_file(filepath, mod_id, chara_id)
   local content = Fs.read_all(filepath)
   local archive = ArchiveUnpacker.unpack_string(content)
   return CustomNpcDecoder.decode(archive, mod_id, chara_id)
end

return CustomNpcDecoder
