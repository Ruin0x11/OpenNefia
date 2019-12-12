local Draw = require("api.Draw")
local Ui = require("api.Ui")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")

local HelpMenuView = class.class("HelpMenuView", {IUiElement, ISettable})

function HelpMenuView:init()
   local text = require("api.Fs").read_all("data/manual_JP.txt")
   self.sections = string.split(text, "{}")
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
            return { title = title, body = body }
         end)
     :to_list()

   self.section = ""
   self.markup = {}
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
      local text = self.sections[self.section]
      if not text then
         text = ("Error: Missing help section '%s'"):format(self.section)
      end
      local err
      markup, err = Ui.parse_elona_markup(text.body, self.width - 40)
      if err then
         markup = { text = ("Invalid markup: %s"):format(err) }
      end
      self.cache[self.section] = markup
   end

   self.markup = markup
   self.redraw = true
end

function HelpMenuView:get_sections()
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

   if self.canvas == nil or width ~= self.width or height ~= self.height then
      self.canvas = Draw.create_canvas(self.width, self.height)
      self.redraw = true
   end

   self:set_data(1)
end

function HelpMenuView:draw()
   if self.redraw then
      Draw.with_canvas(self.canvas, function()
                          Draw.clear()
                          Ui.draw_elona_markup(self.markup, 20, 20, false)
      end)
      self.redraw = false
   end

   Draw.image(self.canvas, self.x, self.y)
end

function HelpMenuView:update()
end

return HelpMenuView
