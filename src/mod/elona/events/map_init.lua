local Calc = require("mod.elona.api.Calc")
local MapgenUtils = require("mod.elona.api.MapgenUtils")
local Event = require("api.Event")
local Effect = require("mod.elona.api.Effect")

local function spawn_random_sites(map, params)
   local amount = Calc.calc_random_site_generate_count(map)

   for _ = 1, amount do
      MapgenUtils.spawn_random_site(map, params.is_first_renewal, nil, nil)
   end
end
Event.register("base.on_map_renew_major", "Spawn random sites", spawn_random_sites, { priority = 250000 })

-- >>>>>>>> shade2/map.hsp:2122 	if mCanSave=true{ ...
local function spoil_items_on_enter(map)
   if not map.is_temporary then
      Effect.spoil_items(map)
   end
end
Event.register("base.on_map_enter", "Spoil items on enter", spoil_items_on_enter, 150000)
-- <<<<<<<< shade2/map.hsp:2124 		} ..