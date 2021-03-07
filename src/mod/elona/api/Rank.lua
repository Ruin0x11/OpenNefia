local Gui = require("api.Gui")
local I18N = require("api.I18N")

local Rank = {}

local function maybe_init_rank(rank_id)
   save.elona.ranks[rank_id] = save.elona.ranks[rank_id] or
      {
         place = 10000,
         days_until_decay = 0
      }
   return save.elona.ranks[rank_id]
end

function Rank.iter()
   local sort = function(a, b)
      return (a.ordering or 0) < (b.ordering or 0)
   end
   local map = function(rank)
      return rank, maybe_init_rank(rank._id)
   end

   return data["elona.rank"]:iter():into_sorted(sort):map(map)
end

function Rank.get(rank_id)
   data["elona.rank"]:ensure(rank_id)
   return maybe_init_rank(rank_id).place
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

   return I18N.get_optional("rank." .. rank_id .. ".titles._" .. index)
   -- <<<<<<<< shade2/init.hsp:1897 	#global ..
end

function Rank.set(rank_id, exp, no_message)
   -- >>>>>>>> shade2/module.hsp:178 	gdata@(p)-=i ...
   data["elona.rank"]:ensure(rank_id)

   local old_exp = Rank.get(rank_id)
   local new_exp = math.clamp(math.floor(exp), 100, 10000)

   maybe_init_rank(rank_id).place = new_exp

   if not no_message then
      local old_rank = math.floor(old_exp/100)
      local new_rank = math.floor(new_exp/100)

      if old_rank ~= new_rank then
         local color

         -- 1st rank is better than 10th rank.
         if new_exp < old_exp then
            color = "Green"
         else
            color = "Purple"
         end

         local name = ("rank.%s.name"):format(rank_id)
         local title = Rank.title(rank_id, new_exp)
         Gui.mes_c("misc.ranking.changed", color, name, old_rank, new_rank, title)
      elseif new_exp < old_exp then
         Gui.mes_c("misc.ranking.closer_to_next_rank", "Green")
      end
   end
   -- <<<<<<<< shade2/module.hsp:190 		} ..
end

function Rank.get_decay_period_days(rank_id)
   local proto = data["elona.rank"]:ensure(rank_id)
   if (proto.decay_period_days or 0) <= 0 then
      return nil
   end
   return math.max(proto.decay_period_days, 1)
end

function Rank.modify(rank_id, delta, limit)
   -- >>>>>>>> shade2/module.hsp:171 	if a>0{ ...
   local old_exp = Rank.get(rank_id)
   local old_rank = math.floor(old_exp / 100)

   local true_delta = delta
   if delta > 0 then
      true_delta = math.floor(delta * ((old_rank + 20) ^ 2) / 2500)

      local days_until_decay = Rank.get_decay_period_days(rank_id)
      if days_until_decay then
         maybe_init_rank(rank_id).days_until_decay = days_until_decay
      end

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
