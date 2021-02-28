local Csv = require("mod.extlibs.api.Csv")
local Compat = require("mod.elona_sys.api.Compat")
local CodeGenerator = require("api.CodeGenerator")

local LOOT_TYPES = {
   animal   = 1,
   insect   = 2,
   humanoid = 3,
   drake    = 4,
   dragon   = 5,
   lich     = 6,
}

local map = function(row)
   local _id = Compat.convert_122_id("base.chara", tonumber(row.id))

   local result = {
      _id = _id:gsub(".*%.", ""),
   }

   assert(LOOT_TYPES[row.loot], row.loot)
   result.loot_type = ("elona.%s"):format(row.loot)

   return result
end

for _, row in Csv.parse_file("../../study/elona122/shade2/db/creature.csv", {header=true, shift_jis=true})
   :filter(function(i) return i.loot ~= "" end)
   :map(map)
do
   local gen = CodeGenerator:new()
   gen:write_table(row)
   print(gen)
end
