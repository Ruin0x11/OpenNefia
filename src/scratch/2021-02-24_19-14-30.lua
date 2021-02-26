local Csv = require("mod.extlibs.api.Csv")
local Compat = require("mod.elona_sys.api.Compat")
local CodeGenerator = require("api.CodeGenerator")

local ELEMENTS = {
    fire = 50,
    cold = 51,
    lightning = 52,
    darkness = 53,
    mind = 54,
    poison = 55,
    nether = 56,
    sound = 57,
    nerve = 58,
    chaos = 59,
    magic = 60,
    cut = 61,
    ether = 62,
    acid = 63
}

local map = function(row)
   local _id = Compat.convert_122_id("base.chara", tonumber(row.id))

   return {
      _id = _id:gsub(".*%.", ""),

      melee_element_id = Compat.convert_122_id("base.element", assert(ELEMENTS[row.elem], row.elem)),
      melee_element_power = tonumber(row.eleP)
   }
end

for _, row in Csv.parse_file("../../study/elona122/shade2/db/creature.csv", {header=true, shift_jis=true})
   :filter(function(i) return i.elem ~= "" end)
   :map(map)
do
   local gen = CodeGenerator:new()
   gen:write_table(row)
   print(gen)
end

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
