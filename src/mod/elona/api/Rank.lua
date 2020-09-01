local Rank = {}

function Rank.get(rank_id)
   return save.elona.ranks[rank_id]
end

function Rank.modify(rank_id, delta, limit)
   -- TODO rank
end

return Rank
