-- Magic, action, and item effects.
--
-- In vanilla, there are three main categories of "effects".
--   Magic: Treated as skills with level/potential.
--   Actions: Activatable through certain menus, items or AI.
--   Effects: Activatable through items only.
--
-- This division accomplished the following:
--   - Magic can be leveled up like passive skills and also be triggered in the
--     code like runEffect(magic_revealMap).
--   - Actions have different damage calculations than magic, because they don't
--     have skill levels, so the damage depends on the casting character's stats
--     instead.
--   - Effects have a predetermined power that is passed in to the effect runner.
--   - All three effect types can be triggered programmatically.
--
-- In OpenNefia, the effect system is decoupled from skill levels and actions.
-- Now the intention is that learnable skills or magic with an associated effect
-- would declare a new "base.skill" entry and label it as an action or magic.
-- That "base.skill" entry would contain a callback which would then call
-- Magic.cast() with the ID of the "elona_sys.magic" entry to trigger. The
-- callback would be run when the magic/action entry is selected in the
-- magic/action menus, which are populated by filtering the list of "base.skill"
-- entries.

require("mod.elona.data.magic.skill")
require("mod.elona.data.magic.unique")
require("mod.elona.data.magic.shared")
require("mod.elona.data.magic.web")
require("mod.elona.data.magic.action")
require("mod.elona.data.magic.effect")
