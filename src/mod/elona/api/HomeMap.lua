local InstancedMap = require("api.InstancedMap")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Log = require("api.Log")

local HomeMap = {}

function HomeMap.generate(home_id, opts)
   opts = opts or {}

   local home = data["elona.home"]:ensure(home_id)

   local map
   if home.map then
      map = Elona122Map.generate(home.map)
   else
      Log.error("Missing map name for home '%s'", home_id)
      map = InstancedMap:new(30, 20)
      map:clear("elona.grass")
   end

   if home.properties then
      table.merge_ex(map, home.properties)
   end

   if not opts.no_callbacks and home.on_generate then
      home.on_generate(map)
   end

   home.is_travel_destination = true

   return map
end

function HomeMap.map_level_text(level)
   -- >>>>>>>> shade2/text.hsp:412 	if gArea=areaHome:if gLevel!1{ ...
   if level == 1 then
      return ""
   elseif level > 0 then
      return ("B.%s"):format(level-1)
   else
      return ("L.%s"):format((level-2)*-1)
   end
   -- <<<<<<<< shade2/text.hsp:414 	} ..
end

return HomeMap
