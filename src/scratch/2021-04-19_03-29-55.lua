local CodeGenerator = require("api.CodeGenerator")
local ItemEx = require("mod.ffhp.api.ItemEx")

for _, row in fun.iter(ItemEx.parse_item_ex_csv("mod/ffhp_matome/graphic/item/itemEx.csv", "mod/ffhp_matome")) do
   local gen = CodeGenerator:new()
   gen:write("data:add ")
   gen:write_table {
   }
   gen:tabify()

   gen:write("data:add ")
   gen:write_table {

   }
   gen:tabify()
   print(gen)
end
