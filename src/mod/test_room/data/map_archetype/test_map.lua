local Fs = require("api.Fs")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local state = require("mod.test_room.internal.global.state")

local function require_all_in(dir)
   return Fs.iter_directory_items(dir, "full_path")
      :map(Fs.convert_to_require_path)
      :map(require)
end

local function add_test_maps(maps)
   -- maps["test_room"] = function() return InstancedMap:new(50, 50) end
   for _id, _ in pairs(maps) do
      data:add {
         _type = "base.map_archetype",
         _id = _id,

         starting_pos = MapEntrance.stairs_up,

         on_generate_map = function(...)
            return maps[_id](...)
         end,

         properties = {
            name = _id,
            is_temporary = true,
            is_renewable = false,
            types = { "guild" }
         }
      }
      state.is_test_map[_MOD_NAME .. "." .. _id] = true
   end
end

local path = "mod/test_room/data/map_archetype/test_map/"
require_all_in(path):each(add_test_maps)
