local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Log = require("api.Log")
local Ui = require("api.Ui")
local Title = require("mod.titles.api.Title")

local IInput = require("api.gui.IInput")
local IPaged = require("api.gui.IPaged")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")

local TitleInformationMenu = class.class("TitleInformationMenu", {IUiLayer, IPaged})

TitleInformationMenu:delegate("input", IInput)
TitleInformationMenu:delegate("model", IPaged)

function TitleInformationMenu:init(entry, list)
   self.width = 600
   self.height = 408

   self.entry = entry
   self.title_name = ""
   self.list = list

   if self.list then
      self.list_index = fun.iter(self.list):index_by(function(other_entry) return other_entry._id == entry._id end)
      if self.list_index == nil then
         Log.warn("Could not find item in provided list, disabling selection feature.")
         self.list = nil
      end
   end

   self.model = PagedListModel:new({}, 15)
   self.win = UiWindow:new("titles.ui.info_menu.title")
   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())

   self:update_desc()
end

function TitleInformationMenu:make_keymap()
   local previous_page = function()
      self:previous_page()
      Gui.play_sound("base.pop1")
   end
   local next_page = function()
      self:next_page()
      Gui.play_sound("base.pop1")
   end

   return {
      cancel = function() self.finished = true end,
      escape = function() self.finished = true end,
      enter = function() self.finished = true end,
      north = function()
         self:previous_item()
      end,
      south = function()
         self:next_item()
      end,
      west = previous_page,
      east = next_page,
      previous_page = previous_page,
      next_page = next_page
   }
end

function TitleInformationMenu:on_query()
   Gui.play_sound("base.pop2")
end

function TitleInformationMenu.build_description(entry, max_width)
   max_width = max_width or 600

   local raw_list = {
      { text = "\n" }
   }

   if Title.state(entry._id) == nil then
      raw_list[#raw_list+1] = { text = I18N.get("titles.ui.info_menu.unacquired") }
      raw_list[#raw_list+1] = { text = "\n" }
   end

   local title_effect = I18N.get_optional("titles.title._." .. entry._id .. ".info.effect")
   if title_effect then
      raw_list[#raw_list+1] = { text = I18N.get("titles.ui.info_menu.title_effect") }
      raw_list[#raw_list+1] = { text = title_effect }
      raw_list[#raw_list+1] = { text = "\n" }
   end

   local title = data["titles.title"]:ensure(entry._id)
   if title.localize_info then
      raw_list = title.localize_info(raw_list)
   end

   if #raw_list <= 1 then
      raw_list[#raw_list+1] = { text = I18N.get("titles.ui.info_menu.no_info") }
   end

   local list = {}

   for _, entry in ipairs(raw_list) do
      local _, wrapped = Draw.wrap_text(entry.text, max_width)
      for _, text in ipairs(wrapped) do
         list[#list+1] = {
            type = entry.type,
            text = text
         }
      end
   end

   return list
end

function TitleInformationMenu:update_desc()
   if self.list then
      self.win:set_title(I18N.get("titles.ui.info_menu.title") .. " " .. string.format("(%d/%d)", self.list_index, #self.list))
   end

   Draw.set_font(13) -- size of flavor text
   local max_width = self.width - (68 * 2) - Draw.text_width(" ")
   local list = TitleInformationMenu.build_description(self.entry, max_width)

   if Title.state(self.entry._id) ~= nil then
      self.title_name = self.entry.name
   else
      self.title_name = I18N.get("titles.ui.info_menu.locked_name")
   end

   self.model:set_data(list)
   self:select_page(0)
end

function TitleInformationMenu:previous_item()
   -- >>>>>>>> oomSEST/src/southtyris.hsp:42806 		snd 5 ...
   if not self.list then return end

   self.list_index = self.list_index - 1
   if self.list_index <= 0 then
      self.list_index = #self.list
   end
   self.entry = self.list[self.list_index]

   Gui.play_sound("base.cursor1")
   self:update_desc()
   -- <<<<<<<< oomSEST/src/southtyris.hsp:42823 		goto *label_1174 ..
end

function TitleInformationMenu:next_item()
   -- >>>>>>>> oomSEST/src/southtyris.hsp:42826 		snd 5 ...
   if not self.list then return end

   self.list_index = self.list_index + 1
   if self.list_index > #self.list then
      self.list_index = 1
   end
   self.entry = self.list[self.list_index]

   Gui.play_sound("base.cursor1")
   self:update_desc()
   -- <<<<<<<< oomSEST/src/southtyris.hsp:42840 		goto *label_1174 ..
end

function TitleInformationMenu:relayout()
   self.x, self.y, self.width, self.height = Ui.params_centered(self.width, self.height)
   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.win:set_pages(self)
end

function TitleInformationMenu:draw()
   -- >>>>>>>> oomSEST/src/southtyris.hsp:42779 	display_window (windoww - 600) / 2 + inf_screenx, ...
   self.win:draw()

   Ui.draw_topic(self.title_name, self.x + 28, self.y + 34)

   for i, entry in self.model:iter() do
      i = i - 1
      local x = self.x + 68
      local y = self.y + 68 + i * 18
      local font = 14 -- 14 - en * 2
      local style
      local color = entry.color or "base.text_color"
      color = self.t[color] or self.t.base.text_color

      if entry.type == "flavor" then
         font = 13 -- 13 - en * 2
      elseif entry.type == "flavor_italic" then
         x = self.x + self.width - Draw.text_width(entry.text) - 80
         font = 13 -- 13 - en * 2
         style = "italic"
      end

      Draw.set_font(font, style)
      Draw.set_color(color)
      Draw.text(entry.text, x, y)
   end
   -- <<<<<<<< oomSEST/src/southtyris.hsp:42801 	loop ..
end

function TitleInformationMenu:update(dt)
   local finished = self.finished

   self.finished = nil
   self.win:update(dt)
   self.win:set_pages(self)

   if finished then
      return self.list_index, nil
   end
end

return TitleInformationMenu
