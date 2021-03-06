local Csv = require("mod.extlibs.api.Csv")
local Compat = require("mod.elona_sys.api.Compat")
local CodeGenerator = require("api.CodeGenerator")

local SKILLS = {
   rje = "elona.jeweler",
   rta = "elona.tailoring",
   ral = "elona.alchemy",
   rca = "elona.carpentry",
}

local MATERIALS = {
   matKuzu = 0,
   matCasinoChip = 1,
   matSumi = 2,
   matDriftwood = 3,
   matFeather = 4,
   matWaterdrop = 5,
   matStaff = 6,
   matMithrilFrag = 7,
   matEtherFrag = 8,
   matSteelFrag = 9,
   matTearAngel = 10,
   matTearWitch = 11,
   matSeaWater = 12,
   matPlant1 = 13,
   matPlant2 = 14,
   matPlant3 = 15,
   matPlant4 = 16,
   matPlant5 = 17,
   matTailRabbit = 18,
   matGenTroll = 19,
   matSnow = 20,
   matFairyDust = 21,
   matElemFrag = 22,
   matElec = 23,
   matBlackMyst = 24,
   matHotWater = 25,
   matFireStone = 26,
   matIceStone = 27,
   matElecStone = 28,
   matFlyingGrass = 29,
   matMagicMass = 30,
   matGenHuman = 31,
   matEyeWitch = 32,
   matLeather = 33,
   matSap = 34,
   matMagicPaper = 35,
   matMagicInk = 36,
   matCrookedStaff = 37,
   matYellMadman = 38,
   matTailBear = 39,
   matCoin1 = 40,
   matCoin2 = 41,
   matPlantHeal = 42,
   matPaper = 43,
   matGenerate = 44,
   matCloth = 45,
   matStick = 46,
   matTightWood = 47,
   matStone = 48,
   matMemoryFrag = 49,
   matMagicFrag = 50,
   matChaosStone = 51,
   matGoodStone = 52,
   matString = 53,
   matAdhesive = 54,
}
for k, v in pairs(MATERIALS) do
   MATERIALS[k:lower()] = v
end

local map = function(row)
   local _id = Compat.convert_122_id("base.item", tonumber(row.id))

   local split1 = string.split(row.make1, "/")
   local split2 = string.split(row.make2, "/")

   local skill_used = assert(SKILLS[split1[1]:lower()], split1[1])
   local required_level = tonumber(split1[2])

   local materials = {}

   for i = 1, #split2/2 do
      local elona_str_id = split2[i*2-1]
      local amount = tonumber(split2[i*2])

      local _id = assert(Compat.convert_122_id("elona.material", MATERIALS[elona_str_id:lower()]), elona_str_id)
      materials[i] = {
         _id = _id,
         amount = amount,
      }
   end

   data["base.skill"]:ensure(skill_used)

   return {
      _type = "elona.crafting_recipe",
      _id = _id,

      item_id = _id,
      skill = skill_used,
      required_skill_level = required_level,
      materials = materials
   }
end

for _, row in Csv.parse_file("../../study/elona122/shade2/db/item.csv", {header=true, shift_jis=true})
   :filter(function(row) return row.make1 ~= "" end)
   :map(map)
do
   local gen = CodeGenerator:new({always_tabify=true})

   gen:write("data:add ")
   gen:write_table_start()
   gen:write_key_value("_type", "elona.crafting_recipe")
   gen:write_key_value("_id", row._id)
   gen:tabify()
   gen:tabify()
   gen:write_key_value("item_id", row.item_id)
   gen:write_key_value("skill_used", row.skill)
   gen:write_key_value("required_skill_level", row.required_skill_level)
   gen:tabify()
   gen:tabify()
   gen:write_key_value("materials", row.materials)
   gen:write_table_end()
   gen:tabify()

   print(gen)
end
