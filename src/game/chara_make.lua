local Draw = require("api.Draw")
local CharaMakeWrapper = require("api.gui.menu.chara_make.CharaMakeWrapper")

local chara_make = {}

local menus = {
   -- "api.gui.menu.chara_make.SelectScenarioMenu",
   -- "api.gui.menu.chara_make.SelectRaceMenu",
   -- "api.gui.menu.chara_make.SelectGenderMenu",
   -- "api.gui.menu.chara_make.SelectClassMenu",
   -- "api.gui.menu.chara_make.RollAttributesMenu",
   -- "api.gui.menu.chara_make.SelectFeatsMenu",
   "api.gui.menu.chara_make.SelectAliasMenu",
   "api.gui.menu.ChangeAppearanceMenu",
   "api.gui.menu.chara_make.CharacterSummaryMenu"
}

function chara_make.query()
   local it = CharaMakeWrapper:new(menus)
   Draw.set_root(it)
   return it:query()
end

return chara_make
