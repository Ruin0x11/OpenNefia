local CharacterSummaryMenu = require("api.gui.menu.chara_make.CharacterSummaryMenu")

local CharacterSummaryMenuExt = {}

local Draw = require("api.Draw")
local Extend = require("api.Extend")
local CharaMake = require("api.CharaMake")

local UiTextGroup = require("api.gui.UiTextGroup")

do
   local super = CharacterSummaryMenu.init
   function CharacterSummaryMenuExt:init(...)
      super(self, ...)
      local history = CharaMake.get_section_result("mod.test.ui.RollBackgroundMenu")
      Extend.extend(self, "background", "data", UiTextGroup:new(history))
   end
end

do
   local super = CharacterSummaryMenu.draw
   function CharacterSummaryMenuExt:draw()
      super(self)
      local it = Extend.get(self, "background", "data")
      if it then it:draw() end
   end
end

do
   local super = CharacterSummaryMenu.relayout
   function CharacterSummaryMenuExt:relayout(...)
      super(self, ...)
      local it = Extend.get(self, "background", "data")
      if it then it:relayout(self.x + 100, self.y + 100) end
   end
end

table.merge(CharacterSummaryMenu, CharacterSummaryMenuExt)

print("i'm exting")

return CharacterSummaryMenuExt
