function math.clamp(i, min, max)
   return math.min(max, math.max(min, i))
end

function math.percent(v, per)
   return math.floor((per / 100) * v)
end

function math.percent_inc(v, per)
   return v + math.percent(v, per)
end

function math.percent_dec(v, per)
   return v - math.percent(v, per)
end
