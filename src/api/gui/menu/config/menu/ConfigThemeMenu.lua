local IInput = require("api.gui.IInput")
local IConfigMenu = require("api.gui.menu.config.IConfigMenu")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local Ui = require("api.Ui")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local InstancedMap = require("api.InstancedMap")
local ConfigThemeMenuPreview = require("api.gui.menu.config.menu.ConfigThemeMenuPreview")
local Chara = require("api.Chara")
local Item = require("api.Item")
local UidTracker = require("api.UidTracker")

local ConfigThemeMenu = class.class("ConfigThemeMenu", IConfigMenu)

ConfigThemeMenu:delegate("input", IInput)

function ConfigThemeMenu:init(config_menu_id)
   self.list = UiList:new_paged({"a", "b", "c"}, 16)

   local key_hints = self:make_key_hints()
   self.win = UiWindow:new("config.menu.base.theme.name", true, key_hints)

   local map = ConfigThemeMenu.build_preview_map()
   self.preview = ConfigThemeMenuPreview:new(map)

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
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
      cancel = function() self.canceled = true end
   }
end

function ConfigThemeMenu:make_key_hints()
   local hints = self.list:make_key_hints()

   hints[#hints+1] = {
      action = "ui.key_hint.action.close",
      keys = { "cancel", "escape" }
   }

   return hints
end

function ConfigThemeMenu:on_query()
   self.canceled = false
end

function ConfigThemeMenu:relayout()
   self.width = 650
   self.height = 500

   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 12

   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   if self.list.page_max > 1 then
      self.win:set_pages(self.list.model)
   end
   self.list:relayout(self.x + 56, self.y + 66)
   self.preview:relayout(self.x + 270, self.y + 44, 48 * 7, 48 * 8)
end

function ConfigThemeMenu:draw()
   self.win:draw()

   Ui.draw_topic("config.common.menu", self.x + 34, self.y + 36)
   self.list:draw()

   self.preview:draw()
end

function ConfigThemeMenu:update(dt)
   local canceled = self.canceled

   self.canceled = false

   self.win:update(dt)
   self.list:update(dt)
   self.preview:update(dt)

   if canceled then
      return nil, "canceled"
   end
end

return ConfigThemeMenu
