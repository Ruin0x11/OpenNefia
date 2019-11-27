local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local TopicWindow = require("api.gui.TopicWindow")
local InputHandler = require("api.gui.InputHandler")
local UiList = require("api.gui.UiList")
local ISettable = require("api.gui.ISettable")
local IUiLayer = require("api.gui.IUiLayer")
local IUiElement = require("api.gui.IUiElement")

local SideBarMenu = class.class("SideBarMenu", {IUiLayer, ISettable})

SideBarMenu:delegate("list", "focus")
SideBarMenu:delegate("input", IInput)

local UiListExt = function(side_bar_menu)
   local E = {}

   function E:get_item_text(entry)
      return Ui.cutoff_text(entry.text, self.width)
   end

   return E
end

function SideBarMenu:init(data, view, in_game, select_on_chosen)
   self.in_game = in_game or false
   self.select_on_chosen = select_on_chosen or false

   self.win = UiWindow:new(view.title or "Elona In-Game Help", true, "key_help")

   self.pages = UiList:new_paged({}, 18)
   table.merge(self.pages, UiListExt(self))

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys {
      shift = function() self.canceled = true end,
      escape = function() self.canceled = true end
   }

   class.assert_is_an(IUiElement, view)
   class.assert_is_an(ISettable, view)
   self.view = view

   self:set_data(data)
end

function SideBarMenu:set_data(data)
   self.pages:set_data(data)
   self:on_select_item()
end

function SideBarMenu:on_select_item()
   local item = self.pages:selected_item()
   self.view:set_data(item.data or item.text)
   self.win:set_pages(self.pages)
end

function SideBarMenu:relayout(x, y, width, height)
   self.width = 780
   self.height = 496
   self.x, self.y = Ui.params_centered(self.width, self.height, self.in_game)

   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 38, self.y + 66, 120, self.height - 66)
   self.view:relayout(self.x + 188, self.y + 6, self.width - 216, self.height - 66)

   self:on_select_item()
end

function SideBarMenu:draw()
   self.win:draw()
   Ui.draw_topic("ui.manual.topic", self.x + 34, self.y + 36)

   local bg = self.t["g" .. ((self.pages.page) % 4 + 1)]
   bg:draw(
      self.x + self.width / 4,
      self.y + self.height / 2,
      self.width / 5 * 2,
      self.height - 80,
      {255, 255, 255, 50},
      true)

   self.pages:draw()
   self.view:draw()
end

function SideBarMenu:on_query()
   self.canceled = false
   self.pages:update()
   self.view:update()
   Gui.play_sound(self.view.sound or "base.pop2")
end

function SideBarMenu:update()
   if self.select_on_chosen then
      if self.pages.chosen then
         self:on_select_item()
      end
   else
      if self.pages.changed or self.pages.chosen then
         self:on_select_item()
      end
   end

   if self.canceled then
      return nil, "canceled"
   end

   if self.pages.changed_page then
      self.win:set_pages(self.pages)
   end

   self.win:update()
   self.pages:update()
   self.view:update()
end

return SideBarMenu
