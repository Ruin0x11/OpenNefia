local CharacterSummaryMenu = require("api.gui.menu.chara_make.CharacterSummaryMenu")

local CharacterSummaryMenuExt = {}

local Draw = require("api.Draw")
local Extend = require("api.Extend")
local CharaMake = require("api.CharaMake")

local UiTextGroup = require("api.gui.UiTextGroup")

-- HACK remove
local MOD_NAME = "test"

do
   local super = CharacterSummaryMenu.init
   function CharacterSummaryMenuExt:init(...)
      super(self, ...)
      local history = CharaMake.get_section_result("mod.test.ui.RollBackgroundMenu")
      Extend.extend(self, MOD_NAME, "data", UiTextGroup:new(history))
      Extend.extend(self, MOD_NAME, "x", math.random(800))
   end
end

do
   local super = CharacterSummaryMenu.draw
   function CharacterSummaryMenuExt:draw()
      super(self)
      local it = Extend.get(self, MOD_NAME, "data")
      if it then it:draw() end
   end
end

do
   local super = CharacterSummaryMenu.relayout
   function CharacterSummaryMenuExt:relayout(...)
      super(self, ...)
      local it = Extend.get(self, MOD_NAME, "data")
      if it then it:relayout(self.x + Extend.get(self, MOD_NAME, "x"), self.y + 100) end
   end
end

table.merge(CharacterSummaryMenu, CharacterSummaryMenuExt)

return CharacterSummaryMenuExt
