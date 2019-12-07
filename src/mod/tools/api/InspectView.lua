local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Ui = require("api.Ui")
local IModdable = require("api.IModdable")
local IUiElement = require("api.gui.IUiElement")
local TopicWindow = require("api.gui.TopicWindow")
local ISettable = require("api.gui.ISettable")

local InspectView = class.class("InspectView", {IUiElement, ISettable})

function InspectView:init(obj)
   self.obj = obj
   self.chip_bg = TopicWindow:new(0, 1)

   self.type = "base.chara"
   self.atlas = "chara"

   self.topic = ""
   self.markup = {}

   self.title = "Inspect"
   self.sound = "base.pop2"
end

function InspectView:set_data(key)
   local value = self.obj[key]
   local extra = ""
   if class.is_an(IModdable, self.obj) and self.obj.temp[key] then
      extra = ("\n<red>Temp value<def>: '%s'"):format(string.tostring_raw(self.obj:calc(key)))
   end

   self.topic = ("%s (%s)"):format(key, type(value))
   local text = ([[
<red>Value<def>: '%s'%s

<red>Added by<def>: %s

Text goes here.
]]):format(string.tostring_raw(value), extra, "some_mod")

   local markup, err = Ui.parse_elona_markup(text, self.width)
   if not markup then
      self.markup = {}
   else
      self.markup = markup
   end
end

function InspectView:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
end

function InspectView:draw()
   Ui.draw_topic(self.topic or "as", self.x + 18, self.y + 30)

   Draw.set_font(14)
   Ui.draw_elona_markup(self.markup, self.x + 38, self.y + 58)
end

function InspectView:update()
end

return InspectView
