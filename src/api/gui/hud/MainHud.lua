local IHud = require("api.gui.hud.IHud")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiBar = require("api.gui.hud.UiBar")
local UiClock = require("api.gui.hud.UiClock")
local UiFpsCounter = require("api.gui.hud.UiFpsCounter")
local UiGoldPlatinum = require("api.gui.hud.UiGoldPlatinum")
local UiLevel = require("api.gui.hud.UiLevel")
local UiMessageWindow = require("api.gui.hud.UiMessageWindow")
local UiMinimap = require("api.gui.hud.UiMinimap")
local UiStatsBar = require("api.gui.hud.UiStatsBar")
local UiStatusEffects = require("api.gui.hud.UiStatusEffects")
local UiSkillTracker = require("api.gui.hud.UiSkillTracker")
local WidgetContainer = require("api.gui.WidgetContainer")
local save = require("internal.global.save")

local MainHud = class.class("MainHud", IHud)
MainHud:delegate("input", IInput)

function MainHud:init()
   self.input = InputHandler:new()

   self.widgets = WidgetContainer:new()

   self.widgets:add(UiMessageWindow:new(), "hud_message_window")
   self.widgets:add(UiStatusEffects:new(), "hud_status_effects")
   self.widgets:add(UiClock:new(), "hud_clock")
   self.widgets:add(UiSkillTracker:new(), "hud_skill_tracker")
   self.widgets:add(UiGoldPlatinum:new(), "hud_gold_platinum")
   self.widgets:add(UiLevel:new(), "hud_level")
   self.widgets:add(UiStatsBar:new(), "hud_stats_bar")
   self.widgets:add(UiMinimap:new(), "hud_minimap")

   local position
   position = function(self, x, y, width, height)
      return math.floor((width - 84) / 2) - 100, height - (72 + 16) - 12
   end
   self.widgets:add(UiBar:new("hud_hp_bar", 0, 0, true), "hud_hp_bar", { position = position })

   position = function(self, x, y, width, height)
      return math.floor((width - 84) / 2) + 40, height - (72 + 16) - 12
   end
   self.widgets:add(UiBar:new("hud_mp_bar", 0, 0, true), "hud_mp_bar", { position = position })

   self.widgets:add(UiFpsCounter:new(), "fps_counter")
end

function MainHud:make_keymap()
   return {}
end

function MainHud:relayout(x, y, width, height)
   self.width = width or self.width
   self.height = height or self.height
   self.x = x or self.x
   self.y = y or self.y

   self.widgets:relayout(self.x, self.y, self.width, self.height)
end

function MainHud:set_date(date)
   self.widgets:get("hud_clock"):set_data(date)
end

function MainHud:update_from_player(player)
   if player == nil then
      return
   end

   -- TODO These should get called when Gui.update_screen() gets called.
   self.widgets:get("hud_hp_bar"):widget():set_data(player.hp, player:calc("max_hp"))
   self.widgets:get("hud_mp_bar"):widget():set_data(player.mp, player:calc("max_mp"))
   self.widgets:get("hud_level"):widget():set_data(player.level, player.experience)
   self.widgets:get("hud_status_effects"):widget():set_data()
   self.widgets:get("hud_stats_bar"):widget():set_data(player)
   self.widgets:get("hud_clock"):widget():set_data(save.base.date)
   self.widgets:get("hud_minimap"):widget():refresh_visible()
   self.widgets:get("hud_skill_tracker"):widget():set_data(player)
end

function MainHud:draw()
   self.widgets:draw()
end

function MainHud:update(dt)
   self.widgets:update(dt)

   if self.widgets.updated and self.x then
      self.widgets:relayout(self.x, self.y, self.width, self.height)
      self.widgets.updated = false
   end
end

return MainHud
