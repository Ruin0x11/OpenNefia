local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local Gui = require("api.Gui")
local global = require("mod.simple_indicators.internal.global")

local UiSimpleIndicatorsWidget = class.class("UiSimpleIndicatorsWidget", {IUiWidget, ISettable})

function UiSimpleIndicatorsWidget:init()
   self.indicators = {}
end

function UiSimpleIndicatorsWidget:default_widget_position(x, y, width, height)
   Draw.set_font(13)
   local th = Draw.text_height()
   height = #self.indicators * th
   return 10, Gui.message_window_y() - 30 - height, width, height
end

function UiSimpleIndicatorsWidget:default_widget_refresh(player)
   self:set_data(player)
end

function UiSimpleIndicatorsWidget:set_data(player)
   self.indicators = {}

   for _, proto in data["simple_indicators.indicator"]:iter() do
      if not global.disabled_indicators[proto._id] then
         local ind = {
            ordering = proto.ordering or 100000,
            text = proto.render(player)
         }
         self.indicators[#self.indicators + 1] = ind
      end
   end

   table.sort(self.indicators, function(a, b) return a.ordering < b.ordering end)
end

function UiSimpleIndicatorsWidget:relayout(x, y)
   self.x = x
   self.y = y
end

function UiSimpleIndicatorsWidget:draw()
   Draw.set_font(13)
   local th = Draw.text_height()
   local x = self.x
   local y = self.y
   for _, ind in ipairs(self.indicators) do
      Draw.text_shadowed(ind.text, x, y)
      y = y + th
   end
end

function UiSimpleIndicatorsWidget:update()
end

return UiSimpleIndicatorsWidget
