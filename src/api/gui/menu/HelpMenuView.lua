local Draw = require("api.Draw")
local Ui = require("api.Ui")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")
local I18N = require("api.I18N")
local ISidebarView = require("api.gui.menu.ISidebarView")
local UiHelpMarkup = require("api.gui.UiHelpMarkup")
local UiTheme = require("api.gui.UiTheme")

local HelpMenuView = class.class("HelpMenuView", {IUiElement, ISettable, ISidebarView})

-- string.split is dumb and doesn't support delimiters with more than 1
-- character...
local function split(str, delimiter)
   local result = {}
   local from  = 1
   local delim_from, delim_to = string.find(str, delimiter, from)
   while delim_from do
      result[#result+1] = string.sub(str, from, delim_from-1)
      from  = delim_to + 1
      delim_from, delim_to = string.find(str, delimiter, from)
   end
   result[#result+1] = string.sub(str, from)
   return result
end

function HelpMenuView:init()
   local text = I18N.get_optional("ui.help.manual")
   if text == nil then
      error("No manual available for language " .. I18N.language_id())
   end
   self.sections = split(text, "{}")
   table.remove(self.sections, 1) -- Remove leading comments
   local remove = {}
   for i, v in ipairs(self.sections) do
      if v == "" then
         remove[#remove+1] = i
      end
   end
   table.remove_indices(self.sections, remove)

   self.sections = fun.iter(self.sections)
     :map(function(sec)
            local pos = string.find(sec, "\n")
            local title, body = string.split_at_pos(sec, pos)
            body = string.strip_whitespace(body)
            return { title = title, body = body }
         end)
     :to_list()

   self.section = ""
   self.markup = nil
   self.cache = {}
   self.canvas = nil
end

function HelpMenuView:set_data(section)
   if self.width == nil then
      return
   end

   self.section = section

   local markup = self.cache[self.section]
   if markup == nil then
      local entry = self.sections[self.section]
      local text
      if entry then
         text = entry.body
      else
         text = ("Error: Missing help section '%s'"):format(self.section)
      end
      markup = UiHelpMarkup:new(text, 14, true)
      self.cache[self.section] = markup
   end

   self.markup = markup
   self.redraw = true
end

function HelpMenuView:get_sidebar_entries()
   return fun.iter(self.sections)
      :enumerate()
      :map(function(i, sec) return { text = sec.title, data = i } end)
      :to_list()
end

function HelpMenuView:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)

   if self.canvas == nil or width ~= self.width or height ~= self.height then
      self.canvas = Draw.create_canvas(self.width, self.height)
      self.redraw = true
   end

   self:set_data(1)
end

function HelpMenuView:draw()
   if self.redraw then
      self.markup:relayout(self.x, self.y, self.width, self.height)
      self.markup:set_color(self.t.elona.help_markup_text_color)
      self.redraw = false
   end

   self.markup:draw()
end

function HelpMenuView:update()
end

return HelpMenuView
