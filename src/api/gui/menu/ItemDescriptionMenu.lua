local Draw = require("api.Draw")
local Ui = require("api.Ui")
local Gui = require("api.Gui")
local Log = require("api.Log")

local IInput = require("api.gui.IInput")
local IPaged = require("api.gui.IPaged")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")

local ItemDescriptionMenu = class("ItemDescriptionMenu", {IUiLayer, IPaged})

ItemDescriptionMenu:delegate("input", IInput)
ItemDescriptionMenu:delegate("model", IPaged)

function ItemDescriptionMenu:init(item, list)
   self.width = 600
   self.height = 408

   self.item = item
   self.list = list

   if self.list then
      self.list_index = fun.iter(self.list):index_by(function(entry) return entry.item.uid == item.uid end)
      if self.list_index == nil then
         Log.warn("Could not find item in provided list, disabling selection feature.")
         self.list = nil
      end
   end

   self.model = PagedListModel:new({}, 15)
   self.win = UiWindow:new("item desc")
   self.input = InputHandler:new()
   self.input:bind_keys {
      shift = function() self.finished = true end,
      escape = function() self.finished = true end,
      up = function()
         self:previous_item()
      end,
      down = function()
         self:next_item()
      end,
      left = function()
         self:previous_page()
         Gui.play_sound("base.pop1")
      end,
      right = function()
         self:next_page()
         Gui.play_sound("base.pop1")
      end,
      ["return"] = function() self.finished = true end,
   }

   self:update_desc()
end

function ItemDescriptionMenu:on_query()
   Gui.play_sound("base.pop2")
end

function ItemDescriptionMenu:update_desc()
   if self.list then
      self.win:set_title("item desc " .. string.format("(%d/%d)", self.list_index, #self.list))
   end

   local data = {
      { text = "This item is in index " .. tostring(self.list_index) .. ": " .. self.item._id },
      { text = "A test description." },
      { text = "Another test description.", color = {80, 100, 0} },
      { text = "Yet another test description.", color = {180, 0, 0}, inherited = true },
      { text = "A flavor text.", type = "flavor" },
      { text = "~A flavor text italic~", type = "flavor_italic" },
      { text = "~Another flavor text italic~", type = "flavor_italic" }
   }

   data = table.flatten(fun.duplicate(data):take(10):to_list())

   self.model:set_data(data)
   self:select_page(0)
end

function ItemDescriptionMenu:previous_item()
   if not self.list then return end

   self.list_index = math.max(1, self.list_index - 1)
   self.item = self.list[self.list_index].item

   Gui.play_sound("base.pop1")
   self:update_desc()
end

function ItemDescriptionMenu:next_item()
   if not self.list then return end

   self.list_index = math.min(#self.list, self.list_index + 1)
   self.item = self.list[self.list_index].item

   Gui.play_sound("base.pop1")
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

   Ui.draw_topic(self.item.name, self.x + 28, self.y + 34)

   for i, entry in self.model:iter() do
      i = i - 1
      local x = self.x + 68
      local y = self.y + 68 + i * 18
      local font = 14 -- 14 - en * 2
      local style
      local color = entry.color or {0, 0, 0}
      local entry_type = entry.type or "normal"

      if entry.type == "flavor" then
         font = 13 -- 13 - en * 2
      elseif entry.type == "flavor_italic" then
         x = self.x + self.width - Draw.text_width(entry.text) - 80
         font = 12 -- 13 - en * 2
         style = "italic"
      end

      Draw.set_font(font, style)
      Draw.text(entry.text, x, y, color)

      Draw.set_color(255, 255, 255)

      if entry_type == "normal" then
         local mark = entry.mark or 1
         self.t.enchantment_icons:draw_region(mark, x - 28, y - 7)
      end

      if entry.inherited then
         self.t.inheritance_icon:draw(x - 53, y - 5)
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
