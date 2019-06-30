local Draw = require("api.Draw")
local Gui = require("api.Gui")
local IUiLayer = require("api.gui.IUiLayer")
local TopicWindow = require("api.gui.TopicWindow")
local InputHandler = require("api.gui.InputHandler")
local UiList = require("api.gui.UiList")
local IInput = require("api.gui.IInput")

local Prompt = class.class("Prompt", IUiLayer)

Prompt:delegate("input", IInput)

local UiListExt = function()
   local E = {}

   function E:get_item_text(item)
      if type(item) == "table" and item.text then
         return item.text
      else
         return tostring(item)
      end
   end
   function E:draw_select_key(item, i, key_name, x, y)
      if item.key then
         key_name = item.key
      end
      UiList.draw_select_key(self, item, i, key_name, x, y)
   end

   return E
end

function Prompt:init(choices, width)
   self.width = width or 160
   self.can_cancel = true

   self.autocenter = true

   self.list = UiList:new(choices, 20)
   table.merge(self.list, UiListExt())

   for i, v in ipairs(choices) do
      if type(v) == "table" and v.key then
         print("bind",v.key)
         self.list:unbind_keys({v.key})
         self.list:bind_keys {
            [v.key] = function()
               self.list:choose(i)
            end
         }
      end
   end

   self.win = TopicWindow:new(0, 0)
   self.radar_deco = Draw.load_image("graphic/temp/radar_deco.bmp")

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys {
      shift = function() if self.can_cancel then self.canceled = true end end,
      escape = function() if self.can_cancel then self.canceled = true end end,
   }
   self.input:halt_input()
end

function Prompt:on_query()
   Gui.play_sound("base.pop2")
end

function Prompt:relayout(x, y)
   if self.autocenter then
      local inf_verh = 16 + 72
      local prompt_x = (Draw.get_width() - 10) / 2 + 3
      local prompt_y = (Draw.get_height() - inf_verh - 30) / 2 - 4 -- inf_verh
      self.x = prompt_x - self.width / 2
      self.y = prompt_y - #self.list.items * 10
   end

   self.height = #self.list.items * 20 + 42

   self.win:relayout(self.x + 8, self.y + 8, self.width - 16, self.height - 16)
   self.list:relayout(self.x + 30, self.y + 24)
end

function Prompt:update()
   if self.list.chosen then
      return { index = self.list.selected, item = self.list:selected_item() }
   end

   if self.canceled then
      return {}, "canceled"
   end

   self.list:update()
end

function Prompt:draw()
   Draw.filled_rect(self.x + 12, self.y + 12, self.width - 17, self.height - 16, {60, 60, 60, 128})
   self.win:draw()
   Draw.image(self.radar_deco, self.x - 16, self.y)
   Draw.set_font(14) -- 14 - en * 2
   self.list:draw()
end

return Prompt
