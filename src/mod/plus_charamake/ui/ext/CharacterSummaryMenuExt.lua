local CharacterSheetMenu = require("api.gui.menu.CharacterSheetMenu")

local CharacterSheetMenuExt = {}

local Draw = require("api.Draw")
local Extend = require("api.Extend")
local CharaMake = require("api.CharaMake")

local IUiElement = require("api.gui.IUiElement")
local Window = require("api.gui.Window")
local UiTextGroup = require("api.gui.UiTextGroup")

local ProfileWindow = class.class("ProfileWindow", IUiElement)

function ProfileWindow:init(history)
   self.history = history
   self.window = Window:new()
   self.text = UiTextGroup:new(history)
end

function ProfileWindow:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.window:relayout(x, y, width, height)
   self.text:relayout(x + 15, y + 15, width, height)
end

function ProfileWindow:draw()
   Draw.set_color(255, 255, 255)
   self.window:draw()
   self.text:draw()
end

function ProfileWindow:update()
end

do
   local super = CharacterSheetMenu.init
   function CharacterSheetMenuExt:init(...)
      super(self, ...)
      local history = CharaMake.get_section_result("mod.plus_charamake.ui.RollBackgroundMenu")
      Extend.extend(self, _MOD_NAME, "data", ProfileWindow:new(history))
   end
end

do
   local super = CharacterSheetMenu.draw
   function CharacterSheetMenuExt:draw()
      super(self)
      local it = Extend.get(self, _MOD_NAME, "data")
      if it then it:draw() end
   end
end

do
   local super = CharacterSheetMenu.relayout
   function CharacterSheetMenuExt:relayout(...)
      super(self, ...)
      local it = Extend.get(self, _MOD_NAME, "data")
      if it then
         it:relayout(self.x + self.width - 70, self.y + self.height - 60, 140, 120)
      end
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
