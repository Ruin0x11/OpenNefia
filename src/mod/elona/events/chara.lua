local Event = require("api.Event")
local LootDrops = require("mod.elona.api.LootDrops")
local Skill = require("mod.elona_sys.api.Skill")
local Equipment = require("mod.elona.api.Equipment")
local Calc = require("mod.elona.api.Calc")
local StayingCharas = require("api.StayingCharas")

local function initialize_equipment(chara, params, equip_spec)
   -- NOTE: the 'kind' is unique for each spec entry, so that an earlier spec
   -- can get overridden by a later one. The order is important to get right so
   -- that, for example, unique weapons will always override the equipment added
   -- by e.g. class default equipment.
   if chara.proto.initial_equipment then
      for key, spec in pairs(chara.proto.initial_equipment) do
         equip_spec[key] = table.deepcopy(spec)
      end
   end

   if chara.proto.on_initialize_equipment then
      chara.proto.on_initialize_equipment(chara, params, equip_spec)
   end
end
Event.register("elona.on_chara_initialize_equipment", "Add special equipment", initialize_equipment)

local function add_mutant_body_parts(chara, params)
   -- >>>>>>>> shade2/chara.hsp:44 	if cnRace(rc)="mutant"{ ...
   if chara.race ~= "elona.mutant" then
      return
   end
   local body_parts_gained = math.floor(chara:calc("level") / 3)
   for _ = 1, body_parts_gained do
      Skill.gain_random_body_part(chara)
   end
   -- <<<<<<<< shade2/chara.hsp:49 		} ..
end
Event.register("base.on_build_chara", "Add mutant body parts", add_mutant_body_parts, { priority = 50000 })

local function generate_initial_equipment(chara, params)
   -- >>>>>>>> shade2/chara.hsp:526 	gosub *chara_initEquip ...
   Equipment.generate_initial_equipment(chara)
   -- <<<<<<<< shade2/chara.hsp:526 	gosub *chara_initEquip ..
end
Event.register("base.on_build_chara", "Generate initial equipment", generate_initial_equipment, { priority = 150000 })

local function proc_on_drop_loot(chara, params, drops)
   if chara.proto.on_drop_loot then
      chara.proto.on_drop_loot(chara, params, drops)
   end
end
Event.register("elona.on_chara_generate_loot_drops", "Run on_drop_loot callback", proc_on_drop_loot)

local function generate_loot(chara, params)
   LootDrops.drop_loot(chara, params.attacker)
end
Event.register("base.on_kill_chara", "Generate loot and drop held items", generate_loot)


local function calc_can_recruit_allies(leader)
   local limit = Calc.calc_ally_limit(leader)

   local party_uid = assert(leader:get_party())
   local party = assert(save.base.parties:get(party_uid))
   local other_member_count = #party.members - 1

   local is_party_leader_of = function(other)
      return leader:is_party_leader_of(other)
   end
   local stayers = StayingCharas.iter_global():filter(is_party_leader_of):length()

   return other_member_count + stayers < limit
end
Event.register("base.on_chara_calc_can_recruit_allies", "Calc can recruit allies", calc_can_recruit_allies)
