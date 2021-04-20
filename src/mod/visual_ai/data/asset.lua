local Fs = require("api.Fs")

local icons = {}
for _, path in Fs.iter_directory_items("mod/visual_ai/graphic/icon", "full_path"):unwrap() do
   local id = ("icon_%s"):format(string.to_snake_case(Fs.filename_part(path)))
   icons[#icons+1] = {
      _id = id,
      image = path
   }
end
data:add_multi("base.asset", icons)

data:add_multi(
   "base.asset",
   {
      {
         _id = "color_block_condition",
         type = "color",
         color = {128, 118, 118}
      },
      {
         _id = "color_block_target",
         type = "color",
         color = {234, 200, 140}
      },
      {
         _id = "color_block_action",
         type = "color",
         color = {140, 180, 210}
      },
      {
         _id = "color_tile_empty",
         type = "color",
         color = {0, 40, 80, 128}
      },
   }
)
