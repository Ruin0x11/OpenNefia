local CharacterSheetMenu = require("api.gui.menu.CharacterSheetMenu")

local CharacterSheetMenuExt = {}

local Draw = require("api.Draw")
local Extend = require("api.Extend")
local CharaMake = require("api.CharaMake")

local UiTextGroup = require("api.gui.UiTextGroup")

-- HACK remove
local MOD_NAME = "test"

do
   local super = CharacterSheetMenu.init
   function CharacterSheetMenuExt:init(...)
      super(self, ...)
      local history = CharaMake.get_section_result("mod.test.ui.RollBackgroundMenu")
      Extend.extend(self, MOD_NAME, "data", UiTextGroup:new(history))
      Extend.extend(self, MOD_NAME, "x", math.random(800))
   end
end

do
   local super = CharacterSheetMenu.draw
   function CharacterSheetMenuExt:draw()
      super(self)
      local it = Extend.get(self, MOD_NAME, "data")
      if it then it:draw() end
   end
end

do
   local super = CharacterSheetMenu.relayout
   function CharacterSheetMenuExt:relayout(...)
      super(self, ...)
      local it = Extend.get(self, MOD_NAME, "data")
      if it then it:relayout(self.x + Extend.get(self, MOD_NAME, "x"), self.y + 100) end
   end
end

local function potential_color(pot)
   if pot >= 200 then
      return {0,0,200}
   elseif pot >= 150 then
      return {0,0,200}
   elseif pot >= 100 then
      return {0,0,0}
   elseif pot >= 50 then
      return {200,0,0}
   end
   return {200,0,0}
end

do
   local super = CharacterSheetMenu.draw_attribute_potential
   function CharacterSheetMenuExt:draw_attribute_potential(attr, x, y)
      local pot = self:potential_string(200)
      local color = potential_color(200)
      Draw.text(pot, x, y, color)
   end
end

table.merge(CharacterSheetMenu, CharacterSheetMenuExt)

return CharacterSheetMenuExt
