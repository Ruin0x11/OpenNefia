local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local UiTheme = require("api.gui.UiTheme")
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

local KEYS = "abcdefghijklmnopqr"

function Prompt.make_list(choices)
   local map = function(index, choice)
      if type(choice) ~= "table" then
         return { index = index, text = I18N.get_optional(choice) or tostring(choice), key = KEYS:sub(index, index), data = nil }
      end

      return {
         text = I18N.get_optional(choice.text) or tostring(choice.text),
         key = choice.key or nil,
         index = choice.index or index
      }
   end

   return fun.iter(choices):enumerate():map(map):to_list()
end

function Prompt:init(choices, width)
   self.can_cancel = true
   self.width = width or 160

   choices = Prompt.make_list(choices)

   local indices = table.set {}

   Draw.set_font(14) -- 14 - en * 2
   for _, choice in ipairs(choices) do
      local text_width = Draw.text_width(choice.text)
      if text_width + 26 + 33 + 44 > self.width then
         self.width = text_width + 26 + 33 + 44
      end

      assert(math.type(choice.index) == "integer", "Choice index must be integer, got " .. tostring(choice.index))
      if indices[choice.index] then
         error("Choice index " .. choice.index .. " was already registered")
      end
      indices[choice.index] = true
   end

   self.list = UiList:new(choices, 20)
   table.merge(self.list, UiListExt())

   for i, v in ipairs(choices) do
      if type(v) == "table" and v.key then
         local key = "raw_" .. v.key
         self.list:unbind_keys({key})
         self.list:bind_keys {
            [key] = function()
               self.list:choose(i)
            end
         }
      end
   end

   self.win = TopicWindow:new(0, 0)

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())
   self.input:halt_input()
end

function Prompt:make_keymap()
   return {
      cancel = function() if self.can_cancel then self.canceled = true end end,
      escape = function() if self.can_cancel then self.canceled = true end end,
   }
end

function Prompt:on_query()
   Gui.play_sound("base.pop2")
end

function Prompt:relayout(x, y)
   local inf_verh = 16 + 72

   self.height = #self.list.items * 20 + 42

   if x == nil or x == 0 then
      local prompt_x = (Draw.get_width() - 10) / 2 + 3
      self.x = prompt_x - self.width / 2
   else
      self.x = x
   end
   if y == nil or y == 0 then
      local prompt_y = (Draw.get_height() - inf_verh - 30) / 2 - 4 -- inf_verh
      self.y = prompt_y - #self.list.items * 10
   else
      self.y = y
   end

   self.t = UiTheme.load(self)

   self.win:relayout(self.x + 8, self.y + 8, self.width - 16, self.height - 16)
   self.list:relayout(self.x + 30, self.y + 24, self.width, self.height)
end

function Prompt:update()
   if self.list.chosen then
      local item = self.list:selected_item()
      return { index = item.index, item = item }
   end

   if self.canceled then
      return {}, "canceled"
   end

   self.list:update()
end

function Prompt:draw()
   Draw.filled_rect(self.x + 12, self.y + 12, self.width - 17, self.height - 16, {60, 60, 60, 128})
   self.win:draw()
   self.t.base.radar_deco:draw(self.x - 16, self.y)
   Draw.set_font(14) -- 14 - en * 2
   self.list:draw()
end

return Prompt
