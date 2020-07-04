local Draw = require("api.Draw")
local Gui = require("api.Gui")
local IUiList = require("api.gui.IUiList")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local ListModel = require("api.gui.ListModel")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")

local ChangeAppearanceList = class.class("ChangeAppearanceList", IUiList)

ChangeAppearanceList:delegate("model", IUiList)
ChangeAppearanceList:delegate("input", IInput)

function ChangeAppearanceList:init(items)
   self.model = ListModel:new({})
   self.item_height = 21
   self.chosen = false

   self.input = InputHandler:new()
   self.input:bind_keys {
      north = function()
         self:select_previous()
         Gui.play_sound("base.cursor1")
      end,
      south = function()
         self:select_next()
         Gui.play_sound("base.cursor1")
      end,
      enter = function() self:choose(self.model:selected_item()) end,
      west = function() self:decrement(self.model:selected_item()) end,
      east = function() self:increment(self.model:selected_item()) end,
   }

   self:set_page(0)
end

function ChangeAppearanceList:set_page(i)
   local data
   if i == 1 then
      data = {
         { text = "body_color", type = "option", value = "base.0" },
         { text = "cloth_color", type = "option", value = "base.0" },
         { text = "pants_color", type = "option", value = "base.0" },
         { text = "etc_1", type = "option", value = "base.0" },
         { text = "etc_2", type = "option", value = "base.0" },
         { text = "etc_3", type = "option", value = "base.0" },
         { text = "eyes", type = "option", value = "base.0" },
         { text = "set_basic", type = "action", action = function() self:set_page(0); self:select(#self.items) end },
      }
   else
      data = {
         { text = "done", type = "confirm", value = "base.0" },
         { text = "portrait", type = "portrait", value = "base.0" },
         { text = "hair", type = "option", value = "base.0" },
         { text = "sub_hair", type = "option", value = "base.0" },
         { text = "hair_color", type = "option", value = "base.0" },
         { text = "body", type = "option", value = "base.0" },
         { text = "cloth", type = "option", value = "base.0" },
         { text = "pants", type = "option", value = "base.0" },
         { text = "set_detail", type = "action", action = function() self:set_page(1); self:select(#self.items) end },
      }

      local is_player = true
      local has_mount = false
      if is_player and has_mount then
         table.insert(data, { text = "mount", type = "option" })
      elseif not is_player then
         table.insert(data, { text = "custom", type = "option" })
      end
   end
   self.model:set_data(data)
end

function ChangeAppearanceList:increment(item)
   if item.type == "action" then
      item.action()
   else
      item.value = "base.1"
   end
   Gui.play_sound("base.cursor1")
end

function ChangeAppearanceList:decrement(item)
   if item.type == "action" then
      item.action()
   else
      item.value = "base.0"
   end
   Gui.play_sound("base.cursor1")
end

function ChangeAppearanceList:choose(item)
   if item.type == "confirm" then
      self.chosen = true
   else
      self:increment(self.model:selected_item())
   end
end

function ChangeAppearanceList:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function ChangeAppearanceList:get_item_color(item)
   return {0, 0, 0}
end

function ChangeAppearanceList:draw_item(item, i, x, y)
   local text
   if item.type == "confirm" or item.type == "action" then
      text = item.text
   else
      text = item.text .. " " .. item.value
   end

   UiList.draw_item_text(self, text, item, i, x, y - 1)

   if item.type ~= "confirm" then
      self.t.base.arrow_left:draw(x - 30, y - 5, nil, nil, {255, 255, 255})
      self.t.base.arrow_right:draw(x + 115, y - 5, nil, nil, {255, 255, 255})
   end
end

function ChangeAppearanceList:draw()
   Draw.set_font(14) -- 14 - en * 2
   for i, item in ipairs(self.items) do
      if self:can_select(self:selected_item(), self.selected) then
         local x = self.x
         local y = (i - 1) * self.item_height + self.y
         self:draw_item(item, i, x, y)
      end
   end
end

function ChangeAppearanceList:update()
   self.chosen = false
end

return ChangeAppearanceList
