local Draw = require("api.Draw")
local Pos = require("api.Pos")
local Gui = require("api.Gui")

local IPaged = require("api.gui.IPaged")
local IUiList = require("api.gui.IUiList")
local UiTheme = require("api.gui.UiTheme")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local UiList = require("api.gui.UiList")

local TargetPromptList = class.class("TargetPromptList", {IUiList, IPaged})

TargetPromptList:delegate("model", IUiList)
TargetPromptList:delegate("model", IPaged)
TargetPromptList:delegate("input", IInput)

function TargetPromptList:init(items, origin_x, origin_y)
   self.origin_x = origin_x
   self.origin_y = origin_y
   self.model = PagedListModel:new(items, 16)

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function TargetPromptList:make_keymap()
   local keys = {
      enter = function() self:choose() end,
      north = function()
         self:select_previous()
         Gui.play_sound("base.cursor1")
      end,
      south = function()
         self:select_next()
         Gui.play_sound("base.cursor1")
      end,
      west = function() self:previous_page() end,
      east = function() self:next_page() end,
   }

   for i=1,#UiList.KEYS do
      local key = "raw_" .. UiList.KEYS:sub(i, i)
      keys[key] = function()
         self:choose(i)
      end
   end

   return keys
end

function TargetPromptList:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
   self.tile_width, self.tile_height = Draw.get_coords():get_size()
end

function TargetPromptList:get_item_color(item)
   return {0, 0, 0}
end

function TargetPromptList:draw_item(item, i, x, y, key_name)
   UiList.draw_select_key(self, item, i, key_name, x, y) -- TODO draw this with a batch
end

function TargetPromptList:draw_line_to(target_x, target_y)
   local x, y = Gui.tile_to_visible_screen(target_x, target_y)
   Draw.set_blend_mode("add")
   Draw.filled_rect(x, y, self.tile_width, self.tile_height, {127, 127, 255, 50})

   for _, tx, ty in Pos.iter_line(self.origin_x, self.origin_y, target_x, target_y) do
      local x, y = Gui.tile_to_visible_screen(tx, ty)
      Draw.filled_rect(x, y, self.tile_width, self.tile_height, {255, 255, 255, 25})
   end
   Draw.set_blend_mode("alpha")
end

function TargetPromptList:draw_target_text(target)
end

function TargetPromptList:draw()
   Draw.set_font(14) -- 14 - en * 2

   local target = self:selected_item()
   self:draw_line_to(target.x, target.y)

   for i, item in ipairs(self.items) do
      if self:can_select(self:selected_item(), self.selected) then
         local x, y = Gui.tile_to_visible_screen(item.x, item.y)
         local key_name = UiList.KEYS:sub(i, i)
         self:draw_item(item, i, x, y, key_name)
      end
   end

   self:draw_target_text(target)
end

function TargetPromptList:update()
   self.chosen = false
end

return TargetPromptList
