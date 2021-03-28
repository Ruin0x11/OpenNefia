local Gui = require("api.Gui")
local Event = require("api.Event")
local UiBar = require("api.gui.hud.UiBar")
local UiBuffs = require("api.gui.hud.UiBuffs")
local UiClock = require("api.gui.hud.UiClock")
local UiGoldPlatinum = require("api.gui.hud.UiGoldPlatinum")
local UiLevel = require("api.gui.hud.UiLevel")
local UiMessageWindow = require("api.gui.hud.UiMessageWindow")
local UiMinimap = require("api.gui.hud.UiMinimap")
local UiStatsBar = require("api.gui.hud.UiStatsBar")
local UiStatusEffects = require("api.gui.hud.UiStatusEffects")
local UiSkillTracker = require("api.gui.hud.UiSkillTracker")
local UiAutoTurn = require("api.gui.hud.UiAutoTurn")

local function add_default_widgets()
   -- TODO to avoid circular dependencies, move all this into a
   -- `base.on_engine_init` handler.
   Gui.add_hud_widget(UiMessageWindow:new(), "hud_message_window")
   Gui.add_hud_widget(UiStatusEffects:new(), "hud_status_effects")
   Gui.add_hud_widget(UiClock:new(), "hud_clock")
   Gui.add_hud_widget(UiSkillTracker:new(), "hud_skill_tracker")
   Gui.add_hud_widget(UiGoldPlatinum:new(), "hud_gold_platinum")
   Gui.add_hud_widget(UiLevel:new(), "hud_level")
   Gui.add_hud_widget(UiStatsBar:new(), "hud_stats_bar")
   Gui.add_hud_widget(UiMinimap:new(), "hud_minimap")
   Gui.add_hud_widget(UiBuffs:new(), "hud_buffs")
   Gui.add_hud_widget(UiAutoTurn:new(), "hud_auto_turn")

   local position, refresh
   position = function(self, x, y, width, height)
      return math.floor((width - 84) / 2) - 100, height - (72 + 16) - 12
   end
   refresh = function(self, player)
      self:set_data(player.hp, player:calc("max_hp"))
   end
   Gui.add_hud_widget(UiBar:new("hud_hp_bar", 0, 0, true), "hud_hp_bar", { position = position, refresh = refresh })

   position = function(self, x, y, width, height)
      return math.floor((width - 84) / 2) + 40, height - (72 + 16) - 12
   end
   refresh = function(self, player)
      self:set_data(player.mp, player:calc("max_mp"))
   end
   Gui.add_hud_widget(UiBar:new("hud_mp_bar", 0, 0, true), "hud_mp_bar", { position = position, refresh = refresh })
end
Event.register("base.before_engine_init", "Add default_widgets", add_default_widgets, {priority = 10000})
