local Ui = require("api.Ui")

text = [[
{} Abilities

<emp1>STR<def>: Strength influences your maximum HP, bonus to close-combat damage,
and the amount of weight you can carry.
<emp1>CON<def>: Constitution influences your maximum HP, stamina, and the amount of
weight you can carry.
<emp1>DEX<def>: Dexterity influences your chances to hit an enemy and provides a
bonus to damage reduction.
<emp1>PER<def>: Perception influences your ability to evade attacks, bonus to ranged
damage, and chance to land a critical hit.
<emp1>LER<def>: Learning influences your maximum MP and your rate of skill growth.
<emp1>WIL<def>: Willpower influences your maximum MP, HP, and stamina.
<emp1>MAG<def>: Magic influences your maximum MP.
<emp1>CHR<def>: Charm influences the way NPCs react to your character.

In addition, the above abilities have influences on skills and spells as
well as events.  The corresponding ability for a spell or skill can be
found to the left of its name in the form of its symbol. (For example,
most weapon skills have a pair of crossed swords to the left of them).

There are also abilities such as <emp1>Life<def>, <emp1>Mana<def>, <emp1>Speed<def>, <emp1>Luck<def>, and <emp1>Stamina<def>,
but these do not grow like the above stats do.
]]

_ppr(Ui.parse_elona_markup(text, 100))
