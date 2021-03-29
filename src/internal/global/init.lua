local hotload = require("internal.hotload")

local global = {}

function global.clear()
   local global_events = require("internal.global.global_events")
   global_events:clear()

   local data = require("internal.data")
   data:clear()

   local Advice = require("api.Advice")
   local advice_state = require("internal.global.advice_state")
   local mod = require("internal.mod")
   for _, mod in mod.iter_loaded() do
      Advice.remove_by_mod(mod.id)
   end
   assert(table.count(advice_state.for_module) == 0)

   local atlases = require("internal.global.atlases")
   atlases.set(nil, nil, nil, nil, nil)

   local env = require("internal.env")
   env.reset()

   -- This will clear the list of loaded mods.
   hotload.hotload("internal.global.main_state")

   local main_state = require("internal.global.main_state")
   assert(table.count(main_state.loaded_mods) == 0)
end

return global
