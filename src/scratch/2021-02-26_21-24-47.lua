local Csv = require("mod.extlibs.api.Csv")
local Compat = require("mod.elona_sys.api.Compat")
local CodeGenerator = require("api.CodeGenerator")

local map = function(row)
   local _id = Compat.convert_122_id("base.chara", tonumber(row.id))

   local equip = fun.iter(string.split(row.equip, '¥')):map(function(i)
         local a = string.split(i, "=")
         local id = tonumber(a[2])
         if id then
            a[2] = Compat.convert_122_id("base.item", id)
         end
         return a
                                                           end):to_list()

   return {
      _id = _id:gsub(".*%.", ""),
      equip = equip
   }
end

for _, row in Csv.parse_file("../../study/elona122/shade2/db/creature.csv", {header=true, shift_jis=true})
   :filter(function(row) return row.equip ~= "" end)
   :map(map)
do
   local gen = CodeGenerator:new()
   gen:write_table(row)
   print(gen)
end
