local Fs = require("api.Fs")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local state = require("mod.test_room.internal.global.state")
local Event = require("api.Event")
local Log = require("api.Log")

local function require_all_in(dir)
   return Fs.iter_directory_items(dir, "full_path")
      :map(Fs.convert_to_require_path)
      :map(require)
end

local function add_test_maps(proto)
   local map = {
      _type = "base.map_archetype",
      _id = proto._id,

      starting_pos = MapEntrance.stairs_up,

      properties = {
         name = proto._id,
         is_temporary = true,
         is_renewable = false,
         types = { "guild" }
      }
   }
   table.merge(map, proto)
   assert(proto.on_generate_map)

   -- hotloading support
   -- BUG but not if you add a new event callback while running
   for k, v in pairs(map) do
      if type(v) == "function" and type(proto[k]) == "function" then
         map[k] = function(...) return proto[k](...) end
      end
   end

   data:add(map)
   state.is_test_map[_MOD_NAME .. "." .. proto._id] = true
end

local path = "mod/test_room/data/map_archetype/test_map/"
require_all_in(path):each(add_test_maps)
