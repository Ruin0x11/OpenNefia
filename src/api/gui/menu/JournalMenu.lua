local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local BookMenuMarkup = require("api.gui.menu.BookMenuMarkup")
local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local UiTheme = require("api.gui.UiTheme")
local ISettable = require("api.gui.ISettable")
local IPaged = require("api.gui.IPaged")

local JournalMenu = class.class("JournalMenu", {IUiLayer, ISettable, IPaged})

JournalMenu:delegate("input", IInput)
JournalMenu:delegate("model", IPaged)

function JournalMenu:init(pages)
   self.max_page_text = 20
   self.max_page_width = 0
   self.input = InputHandler:new()
   self.model = PagedListModel:new({}, 40, false)
   self:set_data(pages)

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function JournalMenu:make_keymap()
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

function JournalMenu:on_query()
   Gui.play_sound("base.book1")
end

function JournalMenu:set_data(pages)
   local all_lines = {}

   Draw.set_font(12)

   for i, page in ipairs(pages) do
      local lines = BookMenuMarkup.parse(page, false)

      for _, line in ipairs(lines) do
         local _, wrapped = Draw.wrap_text(line.line, 280)

         if #wrapped == 0 then
            -- line.line was an empty string ("")
            all_lines[#all_lines+1] = line
         else
            for _, wrap in ipairs(wrapped) do
               local full_line = table.deepcopy(line)
               full_line.line = Draw.make_text(wrap)
               all_lines[#all_lines+1] = full_line
            end
         end
      end

      if i < #pages then
         local blank_lines = 20 - (#all_lines % 20)
         for _ = 1, blank_lines do
            all_lines[#all_lines+1] = { blank = true }
         end
      end
   end

   self.model:set_data(all_lines)
end

function JournalMenu:relayout()
   self.t = UiTheme.load(self)
   self.width = self.t.base.book:get_width()
   self.height = self.t.base.book:get_height()
   self.max_page_width = self.width / 2

   self.x, self.y, self.width, self.height = Ui.params_centered(self.width, self.height)
end

function JournalMenu:draw()
   Draw.set_color(255, 255, 255)
   self.t.base.book:draw(self.x, self.y)

   for i, item in self.model:iter() do
      if not item.blank then
         i = i - 1
         if item.color then
            Draw.set_color(item.color)
         end
         local x = self.x + 80 + math.floor(i / 20) * 306
         local y = self.y + 45 + i % 20 * 16
         Draw.set_font(item.font) -- TODO font style
         Draw.text(item.line, x, y)
         if i % 20 == 0 then
            local page = math.floor(i / 20 + 1) + self.model.page * 2
            Draw.set_font(12, "bold")
            Draw.text(string.format("- %s -", page), x + 90, y + 330)

            if i % 40 == 0 and self.model.page < self.model.page_max then
               Draw.text("(more)", x + 506, y + 330)
            end
         end
      end
   end
end

function JournalMenu:update(dt)
   local canceled = self.canceled

   self.canceled = false
   self.model.changed = false -- TODO bad, make an :update(dt) method instead?

   if canceled then
      return nil, "canceled"
   end
end

return JournalMenu
