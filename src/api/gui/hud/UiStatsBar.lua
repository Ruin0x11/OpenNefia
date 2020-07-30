local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")

local UiStatsBar = class.class("UiStatsBar", {ISettable, IUiWidget})

function UiStatsBar:init()
   self.stats = {
      dv = 0,
      pv = 0
   }
   self.stat_adjusts = {}
end

function UiStatsBar:set_data(player)
   self.stats["dv"] = player:calc("dv")
   self.stats["pv"] = player:calc("pv")

   local attrs = {
      "elona.stat_strength",
      "elona.stat_constitution",
      "elona.stat_dexterity",
      "elona.stat_perception",
      "elona.stat_learning",
      "elona.stat_will",
      "elona.stat_magic",
      "elona.stat_charisma",
      "elona.stat_speed",
   }

   for _, id in ipairs(attrs) do
      self.stats[id] = player:skill_level(id)
      self.stat_adjusts[id] = player:stat_adjustment(id)
   end

   self.stats.original_speed = player:base_skill_level("elona.stat_speed")
   self.stats.final_speed = player:emit("base.on_calc_speed", {}, attrs["elona.stat_speed"])

   local map = player:current_map()
   self.map_name = map and map.name or ""

   local map_level = "B.12"
   local max_width = 16
   if string.nonempty(map_level) then
      max_width = 12
   end
   if utf8.wide_len(self.map_name) > max_width then
      self.map_name = utf8.wide_sub(self.map_name, 0, max_width)
   end
end

function UiStatsBar:default_widget_position(x, y, width, height)
   return x, height - 16, width, 16
end

function UiStatsBar:default_widget_z_order()
   return 60000
end

function UiStatsBar:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)

   self.i_hud_bar = self.t.base.hud_bar:make_instance()
end

function UiStatsBar:draw()
   -- bar
   Draw.set_color(255, 255, 255)
   self.i_hud_bar:draw_bar(self.x, self.y, self.width)

   -- map name
   self.t.base.map_name_icon:draw(self.x + 136 + 6, self.y)
   Draw.set_font(self.t.base.map_name_font) -- 12 + sizefix - en * 2

   Draw.set_color(self.t.base.text_color)
   Draw.text(self.map_name,
             self.x + 136 + 24,
             self.y + 3) -- inf_bary + 3 + vfix - en
   if string.nonempty(self.map_level) then
      Draw.text(self.map_level,
                self.x + 136 + 114,
                self.y + 3) -- inf_bary + 3 + vfix - en
   end

   -- >>>>>>>> shade2/screen.hsp:173 	fontSize 13,0:color 0,0,0 ..
   -- attributes
   local item_width = math.max((Draw.get_width() - 148 - 136) / 11, 47)
   local attrs = {
      "elona.stat_strength",
      "elona.stat_constitution",
      "elona.stat_dexterity",
      "elona.stat_perception",
      "elona.stat_learning",
      "elona.stat_will",
      "elona.stat_magic",
      "elona.stat_charisma",
      "elona.stat_speed",
      "dv_pv"
   }

   -- icons
   Draw.set_color(255, 255, 255)
   for i, a in ipairs(attrs) do
      local x_offset = 0
      if a == "elona.stat_speed" then
         x_offset = 8
      elseif a == "dv_pv" then
         x_offset = 14
      end
      self.t.base.hud_skill_icons:draw_region(
         i,
         self.x + 136 + (i - 1) * item_width + 148 + x_offset,
         self.y + 1)
   end

   -- values
   Draw.set_font(self.t.base.attribute_font) -- 13 - en * 2
   local x
   local y = self.y + 2 -- + vfix
   for i, a in ipairs(attrs) do
      x = self.x + 136 + item_width * (i - 1) + 166
      local color = self.t.base.text_color

      if a == "elona.stat_speed" then
         if self.stats.original_speed > self.stats.final_speed then
            color = self.t.base.stat_penalty_color
         elseif self.stats.original_speed < self.stats.final_speed then
            color = self.t.base.stat_bonus_color
         end
         Draw.text(tostring(self.stats.final_speed), x + 8, y, color)
      elseif a == "dv_pv" then
         local dv_pv = string.format("%d/%d", self.stats["dv"], self.stats["pv"])
         Draw.text(dv_pv, x + 14, y, color)
      else
         local adj = self.stat_adjusts[a]
         if adj < 0 then
            color = self.t.base.stat_penalty_color
         end
         Draw.text(tostring(self.stats[a]), x, y, color)
      end
   end
   -- <<<<<<<< shade2/screen.hsp:193 	loop ..
end

function UiStatsBar:update(dt)
end

return UiStatsBar
