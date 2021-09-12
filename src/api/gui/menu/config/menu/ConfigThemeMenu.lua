local IInput = require("api.gui.IInput")
local IConfigMenu = require("api.gui.menu.config.IConfigMenu")
local InputHandler = require("api.gui.InputHandler")
local Gui = require("api.Gui")
local UiTheme = require("api.gui.UiTheme")
local Ui = require("api.Ui")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local InstancedMap = require("api.InstancedMap")
local ConfigThemeMenuPreview = require("api.gui.menu.config.menu.ConfigThemeMenuPreview")
local Chara = require("api.Chara")
local Item = require("api.Item")
local UidTracker = require("api.UidTracker")
local I18N = require("api.I18N")
local data = require("internal.data")
local config = require("internal.config")

local ConfigThemeMenu = class.class("ConfigThemeMenu", IConfigMenu)

ConfigThemeMenu:delegate("input", IInput)

local UiListExt = function(config_theme_menu)
   local E = {}

   function E:get_item_text(item)
      return item.name
   end
   function E:get_item_color(item)
      if item.enabled == "default" then
         return config_theme_menu.t.base.text_color
      elseif item.enabled then
         return config_theme_menu.t.base.text_color_active
      end
      return config_theme_menu.t.base.text_color_inactive
   end
   function E:draw_item_text(text, item, i, x, y, x_offset, color)
      UiList.draw_item_text(self, text, item, i, x, y, x_offset, color)
      -- Draw.set_color(color)
      -- Draw.text(item.condition, x + 186, y + 2)
   end

   return E
end

function ConfigThemeMenu.generate_list(active_themes)
   local map = function(theme)
      local index = table.index_of(active_themes, theme._id)
      local enabled = index ~= nil
      local name = I18N.localize("base.theme", theme._id, "name")

      local ordering

      if theme._id == "base.default" then
         index = 0
         ordering = -10000000
         enabled = "default"
      elseif index then
         index = index + 1
         ordering = -1000000 + index
         name = ("%s (%d)"):format(name, index)
      else
         ordering = theme._ordering
      end

      return {
         _id = theme._id,
         name = name,
         enabled = enabled,
         index = index or 0,
         ordering = ordering
      }
   end

   local sort = function(a, b) return a.ordering < b.ordering end

   return data["base.theme"]:iter():map(map):into_sorted(sort):to_list()
end

function ConfigThemeMenu:init()
   self.active_themes = table.shallow_copy(config.base.themes)

   local items = ConfigThemeMenu.generate_list(self.active_themes)

   self.pages = UiList:new_paged(items, 16)
   table.merge(self.pages, UiListExt(self))

   local key_hints = self:make_key_hints()
   self.win = UiWindow:new("config.menu.base.theme.name", true, key_hints)

   local map = ConfigThemeMenu.build_preview_map()
   self.preview = ConfigThemeMenuPreview:new(map)

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function ConfigThemeMenu.build_preview_map()
   local uid_tracker = UidTracker:new()
   local map = InstancedMap:new(15, 15, "elona.dirt", uid_tracker, 1)
   assert(map.uid)

   for x = 0, 10-1 do
      map:set_tile(x, 0, "elona.wall_dirt_top")
      if x > 3 then
         map:set_tile(x, 1, "elona.wall_dirt_top")
      end
   end

   Chara.create("elona.putit", 2, 2, {uid_tracker=uid_tracker}, map)
   Chara.create("elona.little_girl", 4, 4, {uid_tracker=uid_tracker}, map)
   Item.create("elona.dagger", 3, 1, {uid_tracker=uid_tracker}, map)
   Item.create("elona.rod_of_teleportation", 3, 4, {uid_tracker=uid_tracker}, map)

   return map
end

function ConfigThemeMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end,
      mode = function()
         self:increase_priority()
      end,
      identify = function()
         self:decrease_priority()
      end,
   }
end

function ConfigThemeMenu:make_key_hints()
   local hints = self.pages:make_key_hints()

   hints[#hints+1] = {
      action = "ui.key_hint.action.close",
      keys = { "cancel", "escape" }
   }

   hints[#hints+1] = {
      action = "config.menu.base.theme.key_hint.increase_priority",
      keys = { "mode" }
   }

   hints[#hints+1] = {
      action = "config.menu.base.theme.key_hint.decrease_priority",
      keys = { "identify" }
   }

   return hints
end

function ConfigThemeMenu:update_list(_id)
   local items = ConfigThemeMenu.generate_list(self.active_themes)
   self.pages:set_data(items)

   local new_index = self.pages:iter():index_by(function(i) return i._id == _id end)
   if new_index then
      self.pages:select(new_index)
   end
end

function ConfigThemeMenu:increase_priority()
   Gui.play_sound("base.ok1")
   local item = self.pages:selected_item()
   if item == nil or not item.enabled then
      return
   end

   local index = table.index_of(self.active_themes, item._id)
   if index <= 1 then
      return
   end

   local temp = self.active_themes[index-1]
   self.active_themes[index-1] = self.active_themes[index]
   self.active_themes[index] = temp

   self:update_list(item._id)
end

function ConfigThemeMenu:decrease_priority()
   Gui.play_sound("base.ok1")
   local item = self.pages:selected_item()
   if item == nil or not item.enabled then
      return
   end

   local index = table.index_of(self.active_themes, item._id)
   if index >= #self.active_themes then
      return
   end

   local temp = self.active_themes[index+1]
   self.active_themes[index+1] = self.active_themes[index]
   self.active_themes[index] = temp

   self:update_list(item._id)
end

function ConfigThemeMenu:relayout()
   self.width = 650
   self.height = 460

   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 12

   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.win:set_pages(self.pages.model)
   self.pages:relayout(self.x + 36, self.y + 66)
   self.preview:relayout(self.x + 270, self.y + 44, 48 * 7, 48 * 7)
end

function ConfigThemeMenu:draw()
   self.win:draw()

   Ui.draw_topic("config.common.menu", self.x + 34, self.y + 36)
   self.pages:draw()

   self.preview:draw()
end

function ConfigThemeMenu:on_choose(index)
   Gui.play_sound("base.ok1")

   local item = self.pages:get(index)
   if item == nil then
      return
   end

   if item.enabled then
      table.iremove_value(self.active_themes, item._id)
   else
      table.insert(self.active_themes, item._id)
   end

   self:update_list(item._id)
end

function ConfigThemeMenu:update(dt)
   local canceled = self.canceled
   local chosen = self.pages.chosen

   self.canceled = false
   self.win:update(dt)
   self.pages:update(dt)
   self.preview:update(dt)

   if chosen then
      self:on_choose(self.pages:selected_index())
   end

   if canceled then
      return nil, "canceled"
   end
end

return ConfigThemeMenu
