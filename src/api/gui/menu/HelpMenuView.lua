local Ui = require("api.Ui")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")

local HelpMenuView = class.class("HelpMenuView", {IUiElement, ISettable})

function HelpMenuView:init()
   local text = require("api.Fs").read_all("data/manual_JP.txt")
   self.sections = string.split(text, "{}")
   local remove = {}
   for i, v in ipairs(self.sections) do
      if v == "" then
         remove[#remove+1] = i
      end
   end
   table.remove_indices(self.sections, remove)

   self.section = ""
   self.markup = {}
end

function HelpMenuView:set_data(section)
   if self.width == nil then
      return
   end

   self.section = section
   local text = self.sections[1] -- self.sections[self.section]
   if not text then
      text = ("Error: Missing help section '%s'"):format(self.section)
   end
   local markup, err = Ui.parse_elona_markup(text, self.width)
   if err then
      markup = { text = ("Invalid markup: %s"):format(err) }
   end

   self.markup = markup
end

function HelpMenuView:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self:set_data(1)
end

function HelpMenuView:draw()
   Ui.draw_elona_markup(self.markup, self.x, self.y, self.width, {30, 30, 30}, false)
end

function HelpMenuView:update()
end

return HelpMenuView
