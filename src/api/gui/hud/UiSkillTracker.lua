local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local I18N = require("api.I18N")
local save = require("internal.global.save")

local UiSkillTracker = class.class("UiSkillTracker", {IUiWidget, ISettable})

function UiSkillTracker:init()
   self.tracked_skill_ids = {}
end

function UiSkillTracker:set_data(player)
   self.player_uid = player.uid

   local tracked_ids = save.base.tracked_skill_ids

   local tracked_pairs = fun.iter(tracked_ids)
      :map(function(i) return { _id = i, name = utf8.sub(I18N.get("ability." .. i .. ".name"), 0, 6)} end)
      :to_list()

   -- TODO save.base
   self.tracked_skill_ids = {
      [self.player_uid] = tracked_pairs
   }
end

function UiSkillTracker:default_widget_position(x, y, width, height)
   return x + 16, y + 155
end

function UiSkillTracker:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
   Draw.set_font(13)
   self.text_height = Draw.text_height()
end

local Map
local Chara

function UiSkillTracker:draw()
   -- HACK
   Map = Map or require("api.Map")

   -- >>>>>>>> shade2/screen.hsp:352 	ap3=0 ...
   local y = self.y

   for uid, tracked in pairs(self.tracked_skill_ids) do
      local chara = Map.current():get_object(uid)
      if chara then
         if uid ~= self.player_uid then
            Draw.text_shadowed(("=== %s"):format(chara.name), self.x, y)
            y = y + self.text_height
         end
         for _, entry in ipairs(tracked) do
            Draw.text_shadowed(entry.name, self.x, y, {255, 255, 255})
            Draw.text_shadowed(("%d.%03d"):format(chara:base_skill_level(entry._id),
                                                  chara:skill_experience(entry._id) % 1000),
                                                  self.x + 50, y)
            y = y + self.text_height
         end
      end
   end


   -- <<<<<<<< shade2/screen.hsp:363 	loop ..
end

function UiSkillTracker:update()
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

   for _, remove in ipairs(remove) do
      self.tracked_skill_ids[remove] = nil
   end
end

return UiSkillTracker
