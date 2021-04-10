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
