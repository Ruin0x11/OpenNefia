local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IHud = require("api.gui.hud.IHud")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiClock = require("api.gui.hud.UiClock")
local UiLevel = require("api.gui.hud.UiLevel")
local UiGoldPlatinum = require("api.gui.hud.UiGoldPlatinum")

local MainHud = class("MainHud", IHud)

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

local function make_skill_icons()
   local image = Draw.load_image("graphic/temp/hud_skill_icons.bmp")

   local iw = image:getWidth()
   local ih = image:getHeight()

   local quad = {}
   for i=1,10 do
      quad[i] = love.graphics.newQuad((i-1) * 16, 0, 16, 48, iw, ih)
   end

   return { image = image, quad = quad }
end

function MainHud:init()
   self.input = InputHandler:new()

   self.bar = nil
   self.message_window = nil
   self.minimap = Draw.load_image("graphic/temp/hud_minimap.bmp")
   self.map_name_icon = Draw.load_image("graphic/temp/map_name_icon.bmp")
   self.skill_icons = make_skill_icons()
   self.clock = UiClock:new()
   self.gold_platinum = UiGoldPlatinum:new()
   self.level = UiLevel:new()
end

function MainHud:relayout(x, y, width, height)
   local regen = self.bar == nil or self.message_window == nil or width % 128 ~= self.width % 128

   self.width = width
   self.height = height
   self.x = x
   self.y = y

   if regen then
      self.bar = make_bar(self.width)
      self.message_window = make_message_window(self.width)
   end

   self.clock:relayout(self.x, self.y)
   self.gold_platinum:relayout(self.width - 240, self.height - (72 + 16))
   self.level:relayout(self.x + 4, self.height - (72 + 16) - 16)
end

function MainHud:set_date(date)
   self.clock:set_date(datae)
end

function MainHud:set_target(chara)
end

function MainHud:register_widget(widget)
end

function MainHud:draw_bar_message_window()
   local step = self.width / 192
   for i=0,step do
      local q
      if i == self.width / 192 - 1 then
         step = self.width % 192
         q = 2
      else
         step = 128
         q = 1
      end

      Draw.image_region(self.bar.image,
                        self.bar.quad[q],
                        i * 192 + self.x,
                        self.height - 16,
                        nil, nil, {255, 255, 255})
      Draw.image_region(self.message_window.image,
                        self.message_window.quad[q],
                        i * 192 + self.x,
                        self.height - (72 + 16),
                        nil, nil, {255, 255, 255})
   end

   Draw.image(self.map_name_icon, 136 + 6, self.height - 16)
end

function MainHud:draw_minimap()
   Draw.image(self.minimap, 0, self.height - (16 + 72), 136, 16 + 72)
end

function MainHud:draw_map_name()
   Draw.set_font(12) -- 12 + sizefix - en * 2

   local map_name = "some_map_name"
   local map_level = "B.12"
   local max_width = 16
   local has_map_level = true
   if string.nonempty(map_level) then
      max_width = 12
   end
   if utf8.wide_len(map_name) > max_width then
      Draw.text(utf8.wide_sub(map_name, 0, max_width),
                136 + 24,
                self.height - 16 + 3, -- inf_bary + 3 + vfix - en
                {0, 0, 0})
   else
      Draw.text(map_name,
                136 + 24,
                self.height - 16 + 3, -- inf_bary + 3 + vfix - en
                {0, 0, 0})
   end
   if string.nonempty(map_level) then
      Draw.text(map_level,
                136 + 114,
                self.height - 16 + 3, -- inf_bary + 3 + vfix - en
                {0, 0, 0})
   end
end

function MainHud:draw_hp_mp_bars()
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
      "dv"
   }

   -- icons
   for i, a in ipairs(attrs) do
      local offset_x = 0
      if a == "base.speed" then
         offset_x = 8
      elseif a == "dv" then
         offset_x = 14
      end
      Draw.image_region(self.skill_icons.image,
                        self.skill_icons.quad[i],
                        136 + (i - 1) * item_width + 148 + offset_x,
                        self.height - 16 + 1,
                        nil,
                        nil,
                        {255, 255, 255})
   end

   -- values
   Draw.set_font(13) -- 13 - en * 2
   local values = table.of(function() return math.random(1000) end, 10)
   local x
   local y = self.height - 16 + 2 -- + vfix
   for i, a in ipairs(attrs) do
      x = 136 + item_width * (i - 1) + 166
      if a == "base.speed" then
         local color = {0, 0, 0}
         Draw.text(tostring(100), x + 8, y, color)
      elseif a == "dv" then
         local dv_pv = string.format("%d/%d", 40, 60)
         Draw.text(dv_pv, x + 14, y, {0, 0, 0})
      else
         local color = {0, 0, 0}
         Draw.text(tostring(100), x, y, color)
      end
   end
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

function MainHud:draw_message_window()
   self.message_window:draw()
end

function MainHud:draw()
   self:draw_bar_message_window()
   self:draw_minimap()
   self:draw_map_name()
   self:draw_hp_mp_bars()
   self:draw_attributes()
   self:draw_clock()
   self:draw_gold_platinum()
   self:draw_player_level()
end

function MainHud:update()
end

return MainHud
