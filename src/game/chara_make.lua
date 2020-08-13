local Draw = require("api.Draw")
local CharaMakeWrapper = require("api.gui.menu.chara_make.CharaMakeWrapper")

local field = require("game.field")

local chara_make = {}

--[[
chara_make.sections = {
   "api.gui.menu.chara_make.SelectScenarioMenu",
   "api.gui.menu.chara_make.SelectRaceMenu",
   "api.gui.menu.chara_make.SelectGenderMenu",
   "api.gui.menu.chara_make.SelectClassMenu",
   "api.gui.menu.chara_make.RollAttributesMenu",
   "api.gui.menu.chara_make.SelectFeatsMenu",
   "api.gui.menu.chara_make.SelectAliasMenu",
   "api.gui.menu.ChangeAppearanceMenu",
   "api.gui.menu.chara_make.CharacterFinalizeMenu"
}
--]]

chara_make.sections = {
   "api.gui.menu.chara_make.SelectScenarioMenu",
   "api.gui.menu.chara_make.ex.TestMenu",
}

chara_make.wrapper = nil

function chara_make.get_section_result(menu)
   return chara_make.wrapper and chara_make.wrapper:get_section_result(menu)
end

function chara_make.make_chara()
   return chara_make.wrapper and chara_make.wrapper:make_chara()
end

function chara_make.set_caption(text)
   return chara_make.wrapper and chara_make.wrapper:set_caption(text)
end

function chara_make.is_active()
   return chara_make.wrapper ~= nil
end

function chara_make.query()
   -- create a new save data so mods can access it
   field:init_global_data()

   chara_make.wrapper = CharaMakeWrapper:new(chara_make.sections)

   local res, canceled = chara_make.wrapper:query()

   chara_make.wrapper = nil

   return res, canceled
end

return chara_make
