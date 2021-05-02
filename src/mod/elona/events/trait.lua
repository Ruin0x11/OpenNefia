local Event = require("api.Event")

-- >>>>>>>> shade2/proc.hsp:1687 	if cc=pc : if trait(traitGodElement):if (ele=rsRe ...
-- TODO data_ext
local ITZPALT_BUFF_TARGETS = table.set {
   "elona.fire",
   "elona.cold",
   "elona.lightning",
}

local function itzpalt_trait(_, params, dice)
   local chara = params.chara
   if not chara or not chara:has_trait("elona.god_element") then
      return dice
   end

   if dice and dice.element then
      if ITZPALT_BUFF_TARGETS[dice.element] then
         dice.y = math.floor(dice.y * 125 / 100)
      end
   end
end
Event.register("elona_sys.calc_magic_dice", "Itzpalt trait buff for elemental spells", itzpalt_trait)
-- <<<<<<<< shade2/proc.hsp:1687 	if cc=pc : if trait(traitGodElement):if (ele=rsRe ...
