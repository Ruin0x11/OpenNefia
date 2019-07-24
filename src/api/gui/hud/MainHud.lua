local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IHud = require("api.gui.hud.IHud")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiBar = require("api.gui.hud.UiBar")
local UiClock = require("api.gui.hud.UiClock")
local UiGoldPlatinum = require("api.gui.hud.UiGoldPlatinum")
local UiLevel = require("api.gui.hud.UiLevel")
local UiMessageWindow = require("api.gui.hud.UiMessageWindow")
local UiStatusEffects = require("api.gui.hud.UiStatusEffects")
local UiTheme = require("api.gui.UiTheme")

local MainHud = class.class("MainHud", IHud)

local function make_bar(width)
   local image = Draw.load_image("graphic/temp/hud_bar.bmp")
   local quad = {}
   local iw = image:getWidth()
   local ih = image:getHeight()

   quad[1] = love.graphics.newQuad(0, 0, 192, 16, iw, ih)

   quad[2] = love.graphics.newQuad(0, 0, width % 192, 16, iw, ih)

   return { image = image, quad = quad }
end

local function make_message_window(width)
   local image = Draw.load_image("graphic/temp/message_window.bmp")
   local quad = {}
   local iw = image:getWidth()
   local ih = image:getHeight()

   quad[1] = love.graphics.newQuad(0, 0, 192, 72, iw, ih)

   quad[2] = love.graphics.newQuad(0, 0, width % 192, 72, iw, ih)

   return { image = image, quad = quad }
end

function MainHud:init()
   self.input = InputHandler:new()

   self.clock = UiClock:new()
   self.gold_platinum = UiGoldPlatinum:new()
   self.level = UiLevel:new()
   self.message_window = UiMessageWindow:new()
   self.hp_bar = UiBar:new("hud_hp_bar", 0, 0, true)
   self.mp_bar = UiBar:new("hud_mp_bar", 0, 0, true)
   self.status_effects = UiStatusEffects:new()

   self.stats = {
      dv = 0,
      pv = 0
   }
end

function MainHud:relayout(x, y, width, height)
   self.width = width
   self.height = height
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)

   self.clock:relayout(self.x, self.y)
   self.gold_platinum:relayout(self.width - 240, self.height - (72 + 16) - 16)
   self.level:relayout(self.x + 4, self.height - (72 + 16) - 16)
   self.message_window:relayout(self.x + 124, self.height - (72 + 16), self.width - 124, 72)
   self.hp_bar:relayout(math.floor((self.width - 84) / 2) - 100, self.height - (72 + 16) - 12)
   self.mp_bar:relayout(math.floor((self.width - 84) / 2) + 40, self.height - (72 + 16) - 12)
   self.status_effects:relayout(self.x + 8, self.height - (72 + 16) - 50)
end

function MainHud:set_date(date)
   self.clock:set_date(datae)
end

function MainHud:set_target(chara)
end

function MainHud:register_widget(widget)
end

function MainHud:refresh(player)
   -- HACK there is a better way of doing this. It almost certainly
   -- has to do with the event system.

   self.stats = { dv = -1, pv = -1 }

   if player ~= nil then
      self.stats["dv"] = player:calc("dv")
      self.stats["pv"] = player:calc("pv")

      self.hp_bar:set_data(player.hp, player:calc("max_hp"))
      self.mp_bar:set_data(player.mp, player:calc("max_mp"))
      self.level:set_data(player.level, player.experience)
      self.status_effects:set_data()
   end
end

function MainHud:find_widget(path)
   -- TODO
   if path == "api.gui.hud.UiMessageWindow" then
      return self.message_window
   elseif path == "api.gui.hud.UiStatusEffects" then
      return self.status_effects
   end

   return nil
end

function MainHud:draw_bar()
   Draw.set_color(255, 255, 255)

   self.t.bar:draw_bar(self.x, self.height - 16, self.width)

   self.t.map_name_icon:draw(self.x + 136 + 6, self.height - 16)
end

function MainHud:draw_minimap()
   self.t.minimap:draw(self.x, self.height - (16 + 72), 136, 16 + 72)
end

function MainHud:draw_map_name()
   Draw.set_font(self.t.map_name_font) -- 12 + sizefix - en * 2

   local map_name = "some_map_name"
   local map_level = "B.12"
   local max_width = 16
   if string.nonempty(map_level) then
      max_width = 12
   end
   Draw.set_color(self.t.text_color)
   if utf8.wide_len(map_name) > max_width then
      Draw.text(utf8.wide_sub(map_name, 0, max_width),
                self.x + 136 + 24,
                self.height - 16 + 3) -- inf_bary + 3 + vfix - en
   else
      Draw.text(map_name,
                self.x + 136 + 24,
                self.height - 16 + 3) -- inf_bary + 3 + vfix - en
   end
   if string.nonempty(map_level) then
      Draw.text(map_level,
                self.x + 136 + 114,
                self.height - 16 + 3) -- inf_bary + 3 + vfix - en
   end
end

function MainHud:draw_hp_mp_bars()
   self.hp_bar:draw()
   self.mp_bar:draw()
end

function MainHud:draw_attributes()
   local item_width = math.max((Draw.get_width() - 148 - 136) / 11, 47)
   local attrs = {
      "base.strength",
      "base.constitution",
      "base.dexterity",
      "base.perception",
      "base.learning",
      "base.will",
      "base.magic",
      "base.charisma",
      "base.speed",
      "dv_pv"
   }

   -- icons
   Draw.set_color(255, 255, 255)
   for i, a in ipairs(attrs) do
      local x_offset = 0
      if a == "base.speed" then
         x_offset = 8
      elseif a == "dv" then
         x_offset = 14
      end
      self.t.skill_icons:draw_region(
         i,
         self.x + 136 + (i - 1) * item_width + 148 + x_offset,
         self.height - 16 + 1)
   end

   -- values
   Draw.set_font(self.t.attribute_font) -- 13 - en * 2
   local x
   local y = self.height - 16 + 2 -- + vfix
   for i, a in ipairs(attrs) do
      x = self.x + 136 + item_width * (i - 1) + 166
      local color = self.t.text_color

      if a == "base.speed" then
         Draw.text(tostring(100), x + 8, y, color)
      elseif a == "dv_pv" then
         local dv_pv = string.format("%d/%d", self.stats["dv"], self.stats["pv"])
         Draw.text(dv_pv, x + 14, y, color)
      else
         Draw.text(tostring(100), x, y, color)
      end
   end
end

function MainHud:draw_message_window()
   self.message_window:draw()
end

function MainHud:draw_clock()
   self.clock:draw()
end

function MainHud:draw_gold_platinum()
   self.gold_platinum:draw()
end

function MainHud:draw_player_level()
   self.level:draw()
end

function MainHud:draw_status_effects()
   self.status_effects:draw()
end

function MainHud:draw()
   self:draw_bar()
   self:draw_minimap()
   self:draw_map_name()
   self:draw_message_window()
   self:draw_hp_mp_bars()
   self:draw_attributes()
   self:draw_clock()
   self:draw_gold_platinum()
   self:draw_player_level()
   self:draw_status_effects()
end

function MainHud:update()
end

return MainHud
