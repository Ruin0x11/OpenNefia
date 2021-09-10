local Gui = require("api.Gui")
local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local Title = require("mod.titles.api.Title")

local IUiLayer = require("api.gui.IUiLayer")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local TitleInformationMenu = require("mod.titles.api.gui.TitleInformationMenu")

local TitlesMenu = class.class("TitlesMenu", IUiLayer)

TitlesMenu:delegate("pages", "chosen")
TitlesMenu:delegate("input", IInput)

local UiListExt = function(feats_menu)
   local E = {}

   function E:get_item_text(item)
      return item.name
   end
   function E:draw_select_key(item, i, key_name, x, y)
      -- >>>>>>>> oomSEST/src/southtyris.hsp:42365 		p = pagesize * page + cnt ...
      if (i - 1) % 2 == 0 then
         Draw.set_blend_mode("subtract")
         Draw.filled_rect(x - 1, y, 640, 18, {12, 14, 16})
         Draw.set_blend_mode("alpha")
      end

      UiList.draw_select_key(self, item, i, key_name, x, y)
      -- <<<<<<<< oomSEST/src/southtyris.hsp:42376 		display_key wx + 58, wy + 66 + cnt * 19 - 2, cnt ..
   end
   function E:get_item_color(item)
      return feats_menu.t[item.color]
   end
   function E:draw_item_text(text, item, i, x, y, x_offset, color)
      -- >>>>>>>> oomSEST/src/southtyris.hsp:42385 		cs_list listn(0, p), wx + x, wy + 66 + cnt * 19  ...
      UiList.draw_item_text(self, text, item, i, x, y, x_offset, color)
      Draw.set_color(color)
      Draw.text(item.condition, x + 186, y + 2)
      -- <<<<<<<< oomSEST/src/southtyris.hsp:42387 		mes titlename2(p) ..
   end

   return E
end

function TitlesMenu.generate_list(chara)
   local locked_name = I18N.get("titles.ui.menu.locked_name")

   local map = function(title)
      local state = Title.state(title._id)
      local title_name
      local color
      if state ~= nil then
         title_name = I18N.get("titles.title._." .. title._id .. ".name")
         if state == "effect_on" then
            color = "titles.text_effect_on"
         elseif state == "earned" then
            color = "base.text_color"
         end
      else
         color = "titles.text_locked"
         title_name = locked_name
      end
      local title_condition = I18N.get("titles.title._." .. title._id .. ".condition")

      return {
         _id = title._id,
         name = title_name,
         condition = title_condition,
         color = color
      }
   end

   return data["titles.title"]:iter():map(map):to_list()
end

function TitlesMenu:init(chara)
   self.chara = chara

   self.data = TitlesMenu.generate_list(self.chara)

   self.pages = UiList:new_paged(self.data, 15)
   table.merge(self.pages, UiListExt(self))

   local key_hints = self:make_key_hints()
   self.win = UiWindow:new("titles.ui.menu.title", true, key_hints, 55, 40)

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function TitlesMenu:make_keymap()
   return {
      identify = function() self:show_title_information() end,
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function TitlesMenu:make_key_hints()
   return {
      {
         action = "titles.ui.menu.hint.action.effect_on_off",
         key_name = "titles.ui.menu.hint.key.enter_key",
         keys = "enter"
      },
      {
         action = "ui.key_hint.action.known_info" ,
         keys = "identify"
      },
      "titles.ui.menu.hint.note"
   }
end

function TitlesMenu:show_title_information()
   local item = self.pages:selected_item()
   if item == nil then
      return
   end
   local rest = self.pages:iter_all_pages():to_list()
   local index = TitleInformationMenu:new(item, rest):query()
   self.pages:select(index)
end

function TitlesMenu:on_query()
   Gui.play_sound("base.feat")
end

function TitlesMenu:relayout(x, y)
   self.width = 730
   self.height = 430
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 66)
   self.win:set_pages(self.pages)
end

function TitlesMenu:draw()
   self.win:draw()

   Ui.draw_topic("titles.ui.menu.header.title_name", self.x + 46, self.y + 36)
   Ui.draw_topic("titles.ui.menu.header.conditions", self.x + 255, self.y + 36)

   self.pages:draw()
end

function TitlesMenu:select()
   -- >>>>>>>> oomSEST/src/southtyris.hsp:42403 	if (p >= 0) { ...
   local item = self.pages:selected_item()

   local state = Title.state(item._id)
   if state == nil then
      return
   end

   Gui.play_sound("base.spend1")

   local color
   if state == "earned" then
      state = "effect_on"
      color = "titles.text_effect_on"
   elseif state == "effect_on" then
      state = "earned"
      color = "base.text_color"
   end

   Title.set_state(item._id, state)
   item.color = color
   -- <<<<<<<< oomSEST/src/southtyris.hsp:42413 	} ..
end

function TitlesMenu:update(dt)
   local canceled = self.canceled
   local changed = self.pages.changed
   local chosen = self.pages.chosen

   self.canceled = nil
   self.win:update(dt)
   self.pages:update(dt)

   if canceled then
      return nil, "canceled"
   end

   if changed then
      self.win:set_pages(self.pages)
   elseif chosen then
      self:select()
   end
end

return TitlesMenu
