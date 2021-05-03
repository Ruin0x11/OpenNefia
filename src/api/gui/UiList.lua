local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local UiTheme = require("api.gui.UiTheme")
local IUiList = require("api.gui.IUiList")
local ListModel = require("api.gui.ListModel")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local IList = require("api.gui.IList")
local IPaged = require("api.gui.IPaged")
local PagedListModel = require("api.gui.PagedListModel")

local UiList = class.class("UiList", IUiList)
UiList:delegate("model", IList)
UiList:delegate("model", IPaged)
UiList:delegate("input", IInput)

UiList.KEYS = "abcdefghijklmnopqr"

function UiList:init(items, item_height, item_offset_x, item_offset_y)
   if class.is_an(IList, items) then
      self.model = items
   else
      self.model = ListModel:new(items)
   end
   self.item_height = item_height or 19
   self.item_offset_x = item_offset_x or 0
   self.item_offset_y = item_offset_y or -2

   self:set_data()

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function UiList:make_keymap()
   local keys = {}
   for i=1,#UiList.KEYS do
      local key = "raw_" .. UiList.KEYS:sub(i, i)
      keys[key] = function()
         self:choose(i)
      end
   end
   keys.north = function()
      self:select_previous()
      Gui.play_sound("base.cursor1")
   end
   keys.south = function()
      self:select_next()
      Gui.play_sound("base.cursor1")
   end
   keys.enter = function() self:choose() end

   if class.is_an(IPaged, self.model) then
      keys.west = function()
         local page = self.page
         self:previous_page()
         if self.page ~= page then
            Gui.play_sound("base.pop1")
         end
      end
      keys.east = function()
         local page = self.page
         self:next_page()
         if self.page ~= page then
            Gui.play_sound("base.pop1")
         end
      end
   end
   return keys
end

function UiList:make_key_hints()
   local hints = {}

   if class.is_an(IPaged, self.model) then
      hints[#hints+1] = {
         action = "ui.key_hint.action.page",
         keys = { "previous_page", "next_page" }
      }
   end

   return hints
end

function UiList:new_paged(items, page_max, item_height, item_offset_x, item_offset_y)
   return UiList:new(PagedListModel:new(items, page_max), item_height, item_offset_x, item_offset_y)
end

function UiList:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)

   -- TODO: use width/height fields for tracking list component
   -- boundaries. currently max entry width is calculated by hand for
   -- every extension of UiList, since that's how vanilla does it.
   self.width = width
   self.height = height

   -- HACK: shouldn't have to keep track of update here.
   self.changed = true
   self.chosen = false
   if class.is_an(IPaged, self.model) then
      self.changed_page = true
   end
end

function UiList:draw_select_key(item, i, key_name, x, y)
   Draw.set_color(255, 255, 255)
   self.t.base.select_key:draw(x, y)
   Draw.set_font(13)
   Draw.text_shadowed(key_name,
                      x + (self.t.base.select_key:get_width() - Draw.text_width(key_name)) / 2 - 2,
                      y + (self.t.base.select_key:get_height() - Draw.text_height()) / 2,
                      self.t.base.text_list_key_name,
                      self.t.base.text_list_key_name_shadow)
end

function UiList:draw_item_text(text, item, i, x, y, x_offset, color)
   local selected = i == self.selected

   x_offset = x_offset or 0
   if selected then
      local width = math.clamp(Draw.text_width(text) + 32 + x_offset, 10, 480)
      Draw.set_blend_mode("subtract")
      Draw.set_color(30, 10, 0)
      Draw.filled_rect(x, y - 2, width, 19)
      Draw.set_blend_mode("add")
      Draw.set_color(50, 50, 50)
      Draw.filled_rect(x+1, y - 1, width-2, 17)
      Draw.set_blend_mode("alpha")
      Draw.set_color(255, 255, 255)
      self.t.base.list_bullet:draw(x + width - 20, y + 2, nil, nil)
   end
   Draw.text(text, x + 4 + x_offset, y + 1, color or {0, 0, 0})
end

function UiList:get_item_color()
   return {0, 0, 0}
end

function UiList:draw_item(item, i, x, y, key_name)
   self:draw_select_key(item, i, key_name, x, y) -- TODO draw this with a batch

   Draw.set_font(14) -- 14 - en * 2

   local text = self:get_item_text(item, i) -- TODO cache this
   local color = self:get_item_color(item)
   self:draw_item_text(text, item, i, x + 26, y + 1, 0, color)
end

function UiList:draw()
   for i, item in ipairs(self.items) do
      local x = self.x + self.item_offset_x
      local y = (i - 1) * self.item_height + self.y + self.item_offset_y
      local key_name = UiList.KEYS:sub(i, i)
      self:draw_item(item, i, x, y, key_name)
   end
end

function UiList:update()
   -- HACK: shouldn't have to keep track of update here.
   local result = nil

   if self.changed then
      self.changed = false
      result = "changed"
   end
   if self.chosen then
      self.chosen = false
      result = "chosen"
   end

   if class.is_an(IPaged, self.model) then
      self.changed_page = false
   end

   return result
end

return UiList
