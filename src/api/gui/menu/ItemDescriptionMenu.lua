local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Log = require("api.Log")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local IPaged = require("api.gui.IPaged")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")

local ItemDescriptionMenu = class.class("ItemDescriptionMenu", {IUiLayer, IPaged})

ItemDescriptionMenu:delegate("input", IInput)
ItemDescriptionMenu:delegate("model", IPaged)

function ItemDescriptionMenu:init(item, list)
   self.width = 600
   self.height = 408

   self.item = item
   self.item_name = ""
   self.list = list

   if self.list then
      self.list_index = fun.iter(self.list):index_by(function(other_item) return other_item.uid == item.uid end)
      if self.list_index == nil then
         Log.warn("Could not find item in provided list, disabling selection feature.")
         self.list = nil
      end
   end

   self.model = PagedListModel:new({}, 15)
   self.win = UiWindow:new("item.desc.window.title")
   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())

   self:update_desc()
end

function ItemDescriptionMenu:make_keymap()
   return {
      cancel = function() self.finished = true end,
      escape = function() self.finished = true end,
      north = function()
         self:previous_item()
      end,
      south = function()
         self:next_item()
      end,
      west = function()
         self:previous_page()
         Gui.play_sound("base.pop1")
      end,
      east = function()
         self:next_page()
         Gui.play_sound("base.pop1")
      end,
      enter = function() self.finished = true end,
   }
end

function ItemDescriptionMenu:on_query()
   Gui.play_sound("base.pop2")
end

function ItemDescriptionMenu.build_description(item, max_width)
   max_width = max_width or 600

   -- src/internal/events/item_description.lua
   local raw_list = item:emit("base.on_item_build_description", {}, {})

   if #raw_list == 0 then
      raw_list = {
         { text = I18N.get("item.desc.no_information") }
      }
   end

   -- Process the raw data by splitting the flavor text strings to fit on multiple lines.
   local list = {}

   for _, entry in ipairs(raw_list) do
      if entry.type == "flavor" then
         local _, wrapped = Draw.wrap_text(entry.text, max_width)
         for _, text in ipairs(wrapped) do
            local new = table.shallow_copy(entry)
            new.text = text
            list[#list+1] = new
         end
      else
         list[#list+1] = entry
      end
   end

   return list
end

function ItemDescriptionMenu:update_desc()
   if self.list then
      self.win:set_title(I18N.get("item.desc.window.title") .. " " .. string.format("(%d/%d)", self.list_index, #self.list))
   end

   Draw.set_font(13) -- size of flavor text
   local max_width = self.width - (68 * 2) - Draw.text_width(" ")
   local list = ItemDescriptionMenu.build_description(self.item, max_width)

   self.item_name = self.item:build_name()
   self.model:set_data(list)
   self:select_page(0)
end

function ItemDescriptionMenu:previous_item()
   if not self.list then return end

   self.list_index = math.max(1, self.list_index - 1)
   self.item = self.list[self.list_index]

   Gui.play_sound("base.cursor1")
   self:update_desc()
end

function ItemDescriptionMenu:next_item()
   if not self.list then return end

   self.list_index = math.min(#self.list, self.list_index + 1)
   self.item = self.list[self.list_index]

   Gui.play_sound("base.cursor1")
   self:update_desc()
end

function ItemDescriptionMenu:relayout()
   self.x, self.y, self.width, self.height = Ui.params_centered(self.width, self.height)
   self.t = UiTheme.load(self)
   print(self.x,self.y,self.width,self.height)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.win:set_pages(self)
end

function ItemDescriptionMenu:draw()
   self.win:draw()

   Ui.draw_topic(self.item_name, self.x + 28, self.y + 34)

   for i, entry in self.model:iter() do
      i = i - 1
      local x = self.x + 68
      local y = self.y + 68 + i * 18
      local font = 14 -- 14 - en * 2
      local style
      local color = entry.color or {0, 0, 0}
      local icon

      if entry.type == "flavor" then
         font = 13 -- 13 - en * 2
      elseif entry.type == "flavor_italic" then
         x = self.x + self.width - Draw.text_width(entry.text) - 80
         font = 12 -- 13 - en * 2
         style = "italic"
      else
         icon = entry.icon or nil
      end

      Draw.set_font(font, style)
      Draw.text(entry.text, x, y, color)

      Draw.set_color(255, 255, 255)

      if icon then
         self.t.base.enchantment_icons:draw_region(icon + 1, x - 28, y - 7)
      end

      if entry.is_inheritable then
         self.t.base.inheritance_icon:draw(x - 53, y - 5)
      end
   end
end

function ItemDescriptionMenu:update()
   if self.finished then
      return true
   end

   self.win:update()
   self.win:set_pages(self)
end

return ItemDescriptionMenu
