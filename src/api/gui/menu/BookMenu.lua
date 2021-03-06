local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")
local BookMenuMarkup = require("api.gui.menu.BookMenuMarkup")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local UiTheme = require("api.gui.UiTheme")
local UiList = require("api.gui.UiList")
local ISettable = require("api.gui.ISettable")
local IPaged = require("api.gui.IPaged")

local BookMenu = class.class("BookMenu", {IUiLayer, ISettable, IPaged})

BookMenu:delegate("input", IInput)
BookMenu:delegate("model", IPaged)

function BookMenu:init(text, elona_compat)
   self.max_page_text = 20
   self.max_page_width = 0
   self.input = InputHandler:new()
   self.model = PagedListModel:new({}, 40, false)
   self:set_data(text)
   self.elona_compat = elona_compat or false

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function BookMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end,
      west = function()
         if self:previous_page() then
            Gui.play_sound("base.card1")
         end
      end,
      east = function()
         if self:next_page() then
            Gui.play_sound("base.card1")
         end
      end,
      enter = function() self.canceled = true end
   }
end

function BookMenu:on_query()
   Gui.play_sound("base.book1")
end

function BookMenu:set_data(text)
   local lines = BookMenuMarkup.parse(text, self.elona_compat)
   self.model:set_data(lines)
end

function BookMenu:relayout()
   self.t = UiTheme.load(self)
   self.width = self.t.base.book:get_width()
   self.height = self.t.base.book:get_height()
   self.max_page_width = self.width / 2

   self.x, self.y, self.width, self.height = Ui.params_centered(self.width - 16, self.height + 20)

end

function BookMenu:draw()
   Draw.set_color(255, 255, 255)
   self.t.base.book:draw(self.x, self.y)

   Draw.set_color(self.t.base.text_color)
   for i, item in self.model:iter() do
      i = i - 1
      local x = self.x + 80 + math.floor(i / 20) * 306
      local y = self.y + 45 + i % 20 * 16
      Draw.set_font(item.font) -- TODO font style
      Draw.text(item.line, x, y)
      if i % 20 == 0 then
         local page = math.floor(i / 20 + 1) + self.model.page * 2
         Draw.set_font(12, "bold")
         Draw.text(string.format("- %s -", page), x + 90, y + 330)
      end
   end
end

function BookMenu:update()
   local canceled = self.canceled

   self.canceled = false
   self.model.changed = false -- TODO bad, make an :update(dt) method instead?

   if canceled then
      return nil, "canceled"
   end
end

return BookMenu
