local Calc = require("mod.elona.api.Calc")
local Rand = require("api.Rand")

local SmithingFormula = {}

function SmithingFormula.calc_hammer_activity_turns(act, params, chara)
   return 25 - chara:trait_level("smithing.blacksmith") * 5 + Rand.rnd(11)
end

function SmithingFormula.calc_smith_extend_chance(hammer, extend)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:98541 			if (rnd(limitmin(200 + extend * 50 - iEnhanceme ..
   return math.max(200 + extend * 50 - hammer.bonus * 100, 1)
   -- <<<<<<<< oomSEST/src/southtyris.hsp:98541 			if (rnd(limitmin(200 + extend * 50 - iEnhanceme ..
end

return SmithingFormula
