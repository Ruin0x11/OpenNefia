local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local ColorBand = require("mod.skill_tracker_ex.api.gui.ColorBand")

local UiSkillTrackerEx = class.class("UiSkillTrackerEx", {IUiWidget, ISettable})

local COLORS = {
   { color = {100, 200, 130}, time = 1.0  },
   { color = {130, 200, 225}, time = 0.5  },
   { color = {255, 200, 130}, time = 0.25 },
   { color = {200, 130, 130}, time = 0.0  }
}

function UiSkillTrackerEx:init()
   self.tracked_skill_ids = {}
end

function UiSkillTrackerEx:set_data(player)
   self.player_uid = player.uid

   local tracked_ids = save.base.tracked_skill_ids

   local function map(i)
      local skill = data["base.skill"]:ensure(i)
      return {
         _id = i,
         name = utf8.sub(I18N.get("ability." .. i .. ".name"), 0, 14),
         icon = Ui.skill_icon(i),
         type = skill.type
      }
   end

   local tracked_pairs = fun.iter(tracked_ids):map(map):to_list()

   self.tracked_skill_ids = {
      [self.player_uid] = tracked_pairs
   }
end

function UiSkillTrackerEx:default_widget_position(x, y, width, height)
   return x + 16, y + 155
end

function UiSkillTrackerEx:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
   Draw.set_font(13)
   self.text_height = Draw.text_height()
   self.gradient = ColorBand:new(COLORS)
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
end

function UiSkillTrackerEx:update()
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
end

return UiSkillTrackerEx
