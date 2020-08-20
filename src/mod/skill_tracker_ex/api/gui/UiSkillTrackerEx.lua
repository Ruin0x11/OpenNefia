local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local ColorBand = require("mod.skill_tracker_ex.api.gui.ColorBand")
local LogWidget = require("mod.tools.api.gui.LogWidget")

local UiSkillTrackerEx = class.class("UiSkillTrackerEx", {IUiWidget, ISettable})

local COLORS = {
   { color = {100, 200, 130}, time = 1.0  },
   { color = {130, 200, 225}, time = 0.5  },
   { color = {255, 200, 130}, time = 0.25 },
   { color = {200, 130, 130}, time = 0.0  }
}

local EXP_COLORS = {
   { color = {100, 200, 130}, time = 1.0  },
   { color = {130, 200, 225}, time = 0.5  },
   { color = {255, 200, 130}, time = 0.00001 },
   { color = {200, 130, 130}, time = 0.0 },
}

function UiSkillTrackerEx:init()
   self.tracked_skill_ids = {}
   self.log_widget = LogWidget:new(4.0, 1.0)
end

function UiSkillTrackerEx:default_widget_refresh(player)
   self:set_data(player)
end

function UiSkillTrackerEx:default_widget_position(x, y, width, height)
   return x + 16, y + 155
end

function UiSkillTrackerEx:set_data(player)
   self.player_uid = player.uid

   local tracked_ids = table.keys(save.base.tracked_skill_ids or {})

   local function map(i)
      local skill = data["base.skill"]:ensure(i)
      return {
         _id = i,
         name = utf8.sub(I18N.get("ability." .. i .. ".name"), 0, 14),
         icon = Ui.skill_icon(i),
         type = skill.type
      }
   end

   local tracked_pairs = fun.iter(tracked_ids)
      :filter(function(i) return player:has_skill(i) end)
      :map(map)
      :to_list()

   self.tracked_skill_ids = {
      [self.player_uid] = tracked_pairs
   }
end

function UiSkillTrackerEx:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
   Draw.set_font(13)
   self.text_height = Draw.text_height()
   self.gradient = ColorBand:new(COLORS)
   self.exp_gradient = ColorBand:new(EXP_COLORS)
   if self.player_uid and self.tracked_skill_ids[self.player_uid] then
      self.log_widget:relayout(self.x, self.y + self.text_height * table.count(self.tracked_skill_ids[self.player_uid]) + 10, self.y, 200, 200)
   end
end

function UiSkillTrackerEx:on_gain_skill_exp(skill_id, base_amount, actual_amount)
   local color = self.exp_gradient:evaluate(actual_amount / 50.0)
   local sign = "+"
   if actual_amount < 0 then
      sign = ""
   end
   local skill_name = I18N.get("ability." .. skill_id .. ".name")
   self.log_widget:print_raw(("%s    %s%d (%s%d)"):format(skill_name, sign, base_amount, sign, actual_amount), color)
end

local Map
local Chara

function UiSkillTrackerEx:draw()
   -- HACK
   Map = Map or require("api.Map")

   local y = self.y

   for uid, tracked in pairs(self.tracked_skill_ids) do
      local chara = Map.current():get_object(uid)
      if chara then
         if uid ~= self.player_uid then
            Draw.text_shadowed(("=== %s"):format(chara.name), self.x, y, {255, 255, 255})
            y = y + self.text_height
         end
         for _, entry in ipairs(tracked) do
            if entry.icon then
               Draw.set_color(255, 255, 255)
               self.t.base.skill_icons:draw_region(entry.icon, self.x - 16, y - 16)
            end
            local potential = chara:skill_potential(entry._id)
            local color = self.gradient:evaluate(potential / 400.0)
            Draw.text_shadowed(entry.name, self.x + 16, y, color)

            local desc = ("%d.%03d (%d%%)"):format(chara:base_skill_level(entry._id),
                                                   chara:skill_experience(entry._id) % 1000,
                                                   potential)
            if entry.type == "spell" then
               desc = desc .. (" [%d]"):format(chara:spell_stock(entry._id))
            end

            Draw.text_shadowed(desc, self.x + 16 + 104, y, color)

            y = y + self.text_height
         end
      end
   end

   self.log_widget:draw()
end

function UiSkillTrackerEx:update(dt)
   -- HACK
   Map = Map or require("api.Map")
   Chara = Chara or require("api.Chara")

   local remove = {}
   for uid, _ in pairs(self.tracked_skill_ids) do
      local chara = Map.current():get_object(uid)
      if not Chara.is_alive(chara) then
         remove[#remove+1] = uid
      end
   end

   for _, i in ipairs(remove) do
      self.tracked_skill_ids[i] = nil
   end

   self.log_widget:update(dt)
end

return UiSkillTrackerEx
