local Draw = require("api.Draw")
local CharaMakeWrapper = require("api.gui.menu.chara_make.CharaMakeWrapper")

local chara_make = {}

local menus = {
   "api.gui.menu.chara_make.SelectRaceMenu",
   "api.gui.menu.chara_make.SelectGenderMenu",
   "api.gui.menu.chara_make.SelectClassMenu",
   "api.gui.menu.chara_make.RollAttributesMenu",
   "api.gui.menu.FeatsMenu",
   "api.gui.menu.chara_make.SelectAliasMenu",
   "api.gui.menu.ChangeAppearanceMenu",
   "api.gui.menu.CharacterSheetMenu"
}

function chara_make.query()
   local it = CharaMakeWrapper:new(menus)
   Draw.set_root(it)
   return it:query()
end

local function on_enter_menu(name)
   local menu, err = pcall(require())

   if err or menu == nil then
      error("Cannot find menu " .. name)
   end

   menu = menu:new()
   on_init_menu(menu)

   return menu
end

local function on_init_menu(menu)
   menu:relayout()
end

return chara_make
