local Event = require("api.Event")
local LootDrops = require("mod.elona.api.LootDrops")
local Skill = require("mod.elona_sys.api.Skill")
local Equipment = require("mod.elona.api.Equipment")

local function initialize_equipment(chara, params, equip_spec)
   if chara.proto.initial_equipment then
      for _, spec in ipairs(chara.proto.initial_equipment ) do
         equip_spec[#equip_spec+1] = table.deepcopy(spec)
      end
   end

   if chara.proto.on_initialize_equipment then
      chara.proto.on_initialize_equipment(chara, params, equip_spec)
   end
end
Event.register("elona.on_chara_initialize_equipment", "Add special equipment", initialize_equipment)

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