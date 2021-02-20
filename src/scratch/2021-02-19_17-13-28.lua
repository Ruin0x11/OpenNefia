local Fs = require("api.Fs")
local CodeGenerator = require("api.CodeGenerator")

local map = function(i)
   local file = ("/home/hiro/build/study/xsokoban/screens/screen.%d"):format(i)

   assert(Fs.exists(file))

   local text = "\n" .. Fs.read_all(file):gsub("(.*)\n$", "%1")

   local gen = CodeGenerator:new()

   gen:write("data:add ")
   gen:write_table_start()
   gen:write_key_value("_type", "sokoban.board")
   gen:write_key_value("_id", ("builtin_%d"):format(i))
   gen:tabify()
   gen:tabify()
   gen:write_key_value("board", CodeGenerator.gen_block_string(text))
   gen:write_table_end()
   gen:tabify()

   return tostring(gen)
end

fun.range(1, 90):map(map):each(print)

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
