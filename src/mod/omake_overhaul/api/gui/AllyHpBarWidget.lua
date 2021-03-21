local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local Gui = require("api.Gui")
local Chara = require("api.Chara")
local UiShadowedText = require("api.gui.UiShadowedText")
local UiTheme = require("api.gui.UiTheme")

local AllyHpBarWidget = class.class("AllyHpBarWidget", {IUiWidget, ISettable})

function AllyHpBarWidget:init()
   self.bars = {}
   self.font_size = 14
end

function AllyHpBarWidget:default_widget_position(x, y, width, height)
   y = 200
   local widget = Gui.hud_widget("hud_clock")
   if widget then
      y = y + widget:widget().height
   end
   if config.omake_overhaul.show_ally_hp_bar == "right_side" then
      y = y - 180
   end
   return 16, y
end

function AllyHpBarWidget:default_widget_refresh(player)
   self:set_data(player)
end

-- TODO theme
local COLOR_ALIVE = {255, 255, 255}
local COLOR_DEAD  = {255, 35, 35}

local COLOR_HP_FULL = {255, 255, 255}
local COLOR_HP_TENTH = {255, 255, 192}
local COLOR_HP_VERY_LOW = {255, 192, 192}

function AllyHpBarWidget:set_data(player)
   self.bars = {}

   -- >>>>>>>> oomSEST/src/net.hsp:1754 		if (cfg_hpgauge) { ...
   for _, chara in player:iter_other_party_members() do
      local is_stethoscoped = chara.is_stethoscoped or true -- TODO
      if Chara.is_alive(chara) or (chara.state == "PetDead" and is_stethoscoped) then
         local name_color
         if Chara.is_alive(chara) then
            name_color = COLOR_ALIVE
         else
            name_color = COLOR_DEAD
         end
         local bar = {
            name = UiShadowedText:new(chara:calc("name"), self.font_size, name_color),
            hp_text = nil,
            bar_width = 0,
         }
         if Chara.is_alive(chara) then
            bar.bar_width = math.clamp(math.floor(chara.hp * 30 / chara:calc("max_hp")), 1, 30)

            local hp_text = ("%d/%d"):format(chara.hp, chara:calc("max_hp"))
            local hp_text_color
            if chara.hp > chara:calc("max_hp") / 2 then
               hp_text_color = COLOR_HP_FULL
            elseif chara.hp > chara:calc("max_hp") / 10 then
               hp_text_color = COLOR_HP_TENTH
            else
               hp_text_color = COLOR_HP_VERY_LOW
            end
            bar.hp_text = UiShadowedText:new(hp_text, self.font_size, hp_text_color)
         end
         self.bars[#self.bars+1] = bar
      end
   end
   -- <<<<<<<< oomSEST/src/net.hsp:1785 		} ..
end

function AllyHpBarWidget:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
   self.bar = self.t.base.hp_bar_ally:make_instance()
end

function AllyHpBarWidget:draw()
   -- >>>>>>>> oomSEST/src/net.hsp:1754 		if (cfg_hpgauge) { ...
   Draw.set_font(self.font_size)
   local draw_right = config.omake_overhaul.show_ally_hp_bar == "right_side"

   for i, bar in ipairs(self.bars) do
      local x = self.x
      local y = self.y + (i-1) * 32
      if draw_right then
         x = Draw.get_width() - bar.name:text_width()
      end

      -- TODO #143
      bar.name:relayout(x, y)
      bar.name:draw()

      if bar.bar_width then
         Draw.set_color(255, 255, 255)
         x = self.x
         if draw_right then
            x = Draw.get_width() - 108
         end
         self.bar:draw_percentage_bar(x, y + 17, bar.bar_width, bar.bar_width * 3, 9)

         y = y + 16

         if bar.hp_text then
            -- TODO #143
            bar.hp_text:relayout(x, y)
            bar.hp_text:draw()
         end
      end
   end
   -- <<<<<<<< oomSEST/src/net.hsp:1785 		} ..
end

function AllyHpBarWidget:update(dt)
end

return AllyHpBarWidget
