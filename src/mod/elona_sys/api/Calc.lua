local Rand = require("api.Rand")

local Calc = {}

function Calc.do_stamina_action(chara, delta)
   chara:damage_sp(delta)
   return chara.stamina >= 50 or chara.stamina >= Rand.rnd(75)
end

function Calc.make_sound(chara)
end

function Calc.make_guards_hostile()
end

return Calc
