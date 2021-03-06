local Csv = require("mod.extlibs.api.Csv")
local Compat = require("mod.elona_sys.api.Compat")
local CodeGenerator = require("api.CodeGenerator")

local map = function(row)
   local _id = Compat.convert_122_id("base.chara", tonumber(row.id))

   local flags = table.set(string.split(row.cBit1, " "))
   local immunities = {}
   local function add_immunity(flag, effect_id)
      if flags[flag] then
         data["base.effect"]:ensure(effect_id)
         immunities[#immunities+1] = effect_id
      end
   end

   add_immunity("cResBlind", "elona.blindness")
   add_immunity("cResConfuse", "elona.confusion")
   add_immunity("cResParalyze", "elona.paralysis")
   add_immunity("cResPoison", "elona.poison")
   add_immunity("cResSleep", "elona.sleep")
   add_immunity("cResFear", "elona.fear")

   if #immunities > 0 then
      return {
         _id = _id:gsub(".*%.", ""),
         effect_immunities = immunities
      }
   end
end

for _, row in Csv.parse_file("../../study/elona122/shade2/db/creature.csv", {header=true, shift_jis=true})
   :filter(function(row) return row.cBit1 ~= "" end)
   :map(map)
   :filter(fun.op.truth)
do
   local gen = CodeGenerator:new()
   gen:write_table(row)
   print(gen)
end
