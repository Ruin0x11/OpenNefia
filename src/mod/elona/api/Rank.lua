local Gui = require("api.Gui")
local I18N = require("api.I18N")

local Rank = {}

function Rank.iter()
   return fun.iter({}) -- TODO rank
end

function Rank.get(rank_id)
   data["elona.rank"]:ensure(rank_id)
   return save.elona.ranks[rank_id] or 10000
end

function Rank.title(rank_id, exp)
   -- >>>>>>>> shade2/init.hsp:1889 	#module ...
   data["elona.rank"]:ensure(rank_id)

   exp = exp or Rank.get(rank_id)

   local rank = math.floor(exp / 100)

   local index
   if rank == 1 then
      index = 0
   elseif rank <= 5 then
      index = 1
   elseif rank <= 10 then
      index = 2
   elseif rank <= 80 then
      index = math.floor(rank/15+3)
   else
      index = 9
   end

   return I18N.get("rank." .. rank_id .. ".titles._" .. index)
   -- <<<<<<<< shade2/init.hsp:1897 	#global ..
end

function Rank.set(rank_id, exp, no_message)
   -- >>>>>>>> shade2/module.hsp:178 	gdata@(p)-=i ...
   data["elona.rank"]:ensure(rank_id)

   local old_exp = Rank.get(rank_id)
   local new_exp = math.clamp(exp, 100, 10000)

   save.elona.ranks[rank_id] = new_exp

   if not no_message then
      local old_rank = math.floor(old_exp/100)
      local new_rank = math.floor(new_exp/100)

      if old_rank ~= new_rank then
         local color
         if new_exp > old_exp then
            color = "Green"
         else
            color = "Purple"
         end

         local name = ("rank.%s.name"):format(rank_id)
         local title = Rank.title(rank_id, new_exp)
         Gui.mes_c("misc.ranking.changed", color, name, old_rank, new_rank, title)
      elseif new_exp > old_exp then
         Gui.mes_c("misc.ranking.closer_to_next_rank", "Green")
      end
   end
   -- <<<<<<<< shade2/module.hsp:190 		} ..
end

function Rank.modify(rank_id, delta, limit)
   -- >>>>>>>> shade2/module.hsp:171 	if a>0{ ...
   local old_exp = Rank.get(rank_id)
   local old_rank = math.floor(old_exp / 100)

   local true_delta = delta
   if delta > 0 then
      true_delta = math.floor(delta * ((old_rank + 20) ^ 2) / 2500)

      -- TODO rank deadline (rankNorma)

      if old_exp == 100 then
         return
      end

      if limit and true_delta / 100 > limit then
         true_delta = limit * 100
      end
   end
   -- <<<<<<<< shade2/module.hsp:176 		} ..

   Rank.set(rank_id, old_exp - true_delta)
end

return Rank
