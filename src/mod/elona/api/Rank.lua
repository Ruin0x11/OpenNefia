local Rank = {}

function Rank.iter()
   return fun.iter({}) -- TODO rank
end

function Rank.get(rank_id)
   return save.elona.ranks[rank_id]
end

function Rank.set(rank_id, exp)
   save.elona.ranks[rank_id] = exp
end

function Rank.modify(rank_id, delta, limit)
   -- TODO rank
end

return Rank
