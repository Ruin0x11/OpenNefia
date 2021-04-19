local Csv = require("mod.extlibs.api.Csv")
local Compat = require("mod.elona_sys.api.Compat")
local CodeGenerator = require("api.CodeGenerator")

local FIGURE_TO_BODY_PART = {
   ["頭"] = "elona.head",
   ["首"] = "elona.neck",
   ["体"] = "elona.body",
   ["背"] = "elona.back",
   ["手"] = "elona.hand",
   ["指"] = "elona.ring",
   ["腕"] = "elona.arm",
   ["腰"] = "elona.waist",
   ["足"] = "elona.leg",
   ["足"] = "elona.leg",
   ["足"] = "elona.leg",
}

local map = function(row)
   local _id = Compat.convert_122_id("base.race", tonumber(string.strip_whitespace(row.id2)))

   local figure = row.figure
   figure = string.split(figure, "|")
   figure = fun.iter(figure)
      :flatmap(function(f) return fun.wrap(utf8.chars(f)):to_list() end)
      :filter(function(f) return f ~= "" end)
      :to_list()

   local body_parts = fun.iter(figure):map(function(f) return assert(FIGURE_TO_BODY_PART[f], f) end):to_list()

   return {
      _id = row.id,
      elona_id = assert(tonumber(string.strip_whitespace(row.id2))),
      body_parts = body_parts
   }
end

for _, row in Csv.parse_file("../../study/elona122/shade2/db/race.csv", {header=true, shift_jis=true})
   :map(map)
   :filter(fun.op.truth)
do
   local gen = CodeGenerator:new()
   gen:write_table(row)
   print(gen)
end
