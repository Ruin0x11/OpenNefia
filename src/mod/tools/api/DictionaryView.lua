local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Ui = require("api.Ui")
local IUiElement = require("api.gui.IUiElement")
local TopicWindow = require("api.gui.TopicWindow")
local ISettable = require("api.gui.ISettable")

local DictionaryView = class.class("DictionaryView", {IUiElement, ISettable})

function DictionaryView:init()
   self.chip_bg = TopicWindow:new(0, 1)

   self.type = "base.chara"
   self.atlas = "chara"

   self.data = nil
   self.image = nil

   self.title = "Dictionary"
   self.sound = "base.spell"
end

function DictionaryView:get_sidebar_entries()
  return data["base.chara"]:iter():extract("_id"):map(function(id) return { text = id, data = id } end):to_list()
end

function DictionaryView:set_data(id)
   self.data = data[self.type][id]

   if self.image then
      self.image:release()
      self.image = nil
   end

   if self.data then
      self.image = Chara.create(id, nil, nil, {ownerless=true}):calc("image")
   end
end

function DictionaryView:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.chip_bg:relayout(self.x + self.width - 128, self.y + 48, 96, 128)
end

function DictionaryView:draw()
   Ui.draw_topic("Vitals", self.x + 18, self.y + 30)

   if self.data == nil then
      Draw.text(("No data for '%s:%s'"):format(self.type, self.id), self.x + 38, self.y + 58, {0, 0, 0})
      return
   end

   self.chip_bg:draw()
   if self.image then
      local offset_y = 0
      local is_tall = data["base.chip"][self.image].is_tall
      if is_tall then
         offset_y = -24
      end
      Draw.chip(self.image, self.x + self.width - 128 + 48, self.y + 48 + 72 + offset_y, nil, nil, {255, 255, 255}, true)
   end

   Draw.text(("ID: %s"):format(self.data._id), self.x + 38, self.y + 58, {0, 0, 0})
end

function DictionaryView:update()
end

return DictionaryView
