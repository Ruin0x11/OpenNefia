local Feat = require("api.Feat")
local Event = require("api.Event")
local Rand = require("api.Rand")
local Item = require("api.Item")
local Gardening = require("mod.elona.api.Gardening")
local Autoplant = require("mod.autoplant.api.Autoplant")

local function proc_autoplant(chara, p, result)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:67927 		if (key_ctrl) { ...
   if not Autoplant.is_enabled() then
      return
   end

   local map = chara:current_map()
   if Item.at(p.x, p.y, map):length() > 0 then
      return
   end
   if Feat.at(p.x, p.y, map):length() > 0 then
      return
   end

   local seeds = Autoplant.find_autoplantable_seeds(chara)

   if #seeds > 0 then
      local seed = Rand.choice(seeds)
      Gardening.plant_seed(seed, chara, p.x, p.y)
   end
   -- <<<<<<<< oomSEST/src/southtyris.hsp:67963 		} ..
end
Event.register("base.on_chara_moved", "Proc autoplant", proc_autoplant, { priority = 200000 })
