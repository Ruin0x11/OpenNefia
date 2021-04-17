local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local I18N = require("api.I18N")
local save = require("internal.global.save")
local UiShadowedText = require("api.gui.UiShadowedText")
local Map = require("api.Map")
local Chara = require("api.Chara")

local UiSkillTracker = class.class("UiSkillTracker", {IUiWidget, ISettable})

function UiSkillTracker:init()
   self.tracked_skill_ids = {}
end

function UiSkillTracker:default_widget_position(x, y, width, height)
   return x + 16, y + 155
end

function UiSkillTracker:default_widget_refresh(player)
   self:set_data(player)
end

function UiSkillTracker:set_data(player)
   self.tracked_skill_ids = {}

   self.player_uid = player.uid

   local tracked_ids = table.keys(save.base.tracked_skill_ids or {})

   local map = function(skill_id)
      local name = utf8.sub(I18N.localize("base.skill", skill_id, "name"), 0, 6)
      local desc = ("%d.%03d"):format(player:base_skill_level(skill_id),
                         player:skill_experience(skill_id) % 1000)

      return {
         _id = skill_id,
         name_text = UiShadowedText:new(name),
         desc_text = UiShadowedText:new(desc)
      }
   end

   local tracked_pairs = fun.iter(tracked_ids)
      :filter(function(i) return player:has_skill(i) end)
      :map(map)
      :to_list()

      self.tracked_skill_ids[self.player_uid] = {
         chara_name = nil,
         tracked_pairs = tracked_pairs
      }
end

function UiSkillTracker:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
   Draw.set_font(13)
   self.text_height = Draw.text_height()
end

function UiSkillTracker:draw()
   -- >>>>>>>> shade2/screen.hsp:352 	ap3=0 ...
   local y = self.y

   for uid, tracked in pairs(self.tracked_skill_ids) do
      if tracked.chara_name then
         Draw.text_shadowed(("=== %s"):format(tracked.chara_name), self.x, y)
         y = y + self.text_height
      end
      for _, entry in ipairs(tracked.tracked_pairs) do
         entry.name_text:relayout(self.x, y)
         entry.name_text:draw()

         entry.desc_text:relayout(self.x + 50, y)
         entry.desc_text:draw()

         y = y + self.text_height
      end
   end
   -- <<<<<<<< shade2/screen.hsp:363 	loop ..
end

function UiSkillTracker:update()
   local remove = {}
   for uid, _ in pairs(self.tracked_skill_ids) do
      local chara = Map.current():get_object(uid)
      if not Chara.is_alive(chara) then
         remove[#remove+1] = uid
      end
   end

   for _, remove in ipairs(remove) do
      self.tracked_skill_ids[remove] = nil
   end
end

return UiSkillTracker
