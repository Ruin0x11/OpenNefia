local Event = require("api.Event")
local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Calc = require("mod.elona.api.Calc")
local Itemgen = require("mod.elona.api.Itemgen")
local Item = require("api.Item")

local function kumiromi_harvest_seeds(item, params)
   -- >>>>>>>> shade2/item.hsp:425 		if p=pc : if cGod(pc)=godHarvest : i=iTypeMinor( ...
   local chara = params.owning_chara
   if not (Chara.is_alive(chara) and chara:is_player() and chara:calc("god") == "elona.kumiromi") then
      return
   end

   if Rand.one_in(3) then
      local seed_amount = Rand.rnd(item.amount) + 1
      Gui.mes("misc.extract_seed", item:build_name(seed_amount))
      item:remove(seed_amount)
      local filter = {
         level = Calc.calc_object_level(chara:calc("level"), chara:current_map()),
         categories = { "elona.crop_seed" },
         amount = seed_amount
      }
      Itemgen.create(nil, nil, filter, chara)
   end
   -- <<<<<<<< shade2/item.hsp:430 		} ...
end
Event.register("elona.on_item_rot", "Kumiromi: Harvest seeds from rotten food", kumiromi_harvest_seeds, { priority = 120000 })

local function ehekatl_mp_cost(chara, params, mp_cost)
   -- >>>>>>>> shade2/proc.hsp:1307 		if cc=pc:if cGod(pc)=godLuck:mp=rnd(mp*140/100+1 ...
   if chara:is_player() and chara:calc("god") == "elona.ehekatl" then
      return Rand.rnd(mp_cost * 140 / 100 + 1) + 1
   end

   return mp_cost
   -- <<<<<<<< shade2/proc.hsp:1307 		if cc=pc:if cGod(pc)=godLuck:mp=rnd(mp*140/100+1 ..
end
Event.register("elona_sys.calc_chara_spell_mp_cost", "Ehekatl: Adjust spell MP cost", ehekatl_mp_cost, { priority = 100000 })
