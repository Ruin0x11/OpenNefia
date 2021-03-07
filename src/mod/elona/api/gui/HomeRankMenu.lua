local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local Home = require("mod.elona.api.Home")
local UiShadowedText = require("api.gui.UiShadowedText")

local IUiLayer = require("api.gui.IUiLayer")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")

local HomeRankMenu = class.class("HomeRankMenu", IUiLayer)

HomeRankMenu:delegate("input", IInput)

function HomeRankMenu.generate_list(most_valuable)
   local map = function(i, entry)
      -- { item = item, value = 850 }
      local item = entry.item
      return {
         chip_id = item:calc("image"),
         chip_color = item:calc("color"),
         rank_text = I18N.get("building.home.rank.place", i),
         item_name = item:build_name()
      }
   end

   return fun.iter(most_valuable):enumerate():map(map):to_list()
end

function HomeRankMenu:init(most_valuable, base_value, home_value, furniture_value)
   self.data = HomeRankMenu.generate_list(most_valuable)
   self.base_value = base_value
   self.home_value = home_value
   self.furniture_value = furniture_value
   self.total_value = Home.calc_total_value(base_value, home_value, furniture_value)

   self.win = UiWindow:new("building.home.rank.title", true, "building.home.rank.enter_key")

   self.star = nil
   self.chip_batch = nil

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())

   self.bg = Ui.random_cm_bg()
end

function HomeRankMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end,
      enter  = function() self.canceled = true end
   }
end

function HomeRankMenu:on_query()
end

function HomeRankMenu:relayout(x, y)
   self.width = 440
   self.height = 360
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)
   self.chip_batch = Draw.make_chip_batch("chip")

   Draw.set_font(14)
   local star = I18N.get("building.home.rank.star")
   self.star = UiShadowedText:new(star, 14, {255, 255, 50}, {0, 0, 0})
   self.star_width = Draw.text_width(star)

   self.win:relayout(self.x, self.y, self.width, self.height)
end

local HEADERS = {
   "building.home.rank.type.base",
   "building.home.rank.type.deco",
   "building.home.rank.type.heir",
   "building.home.rank.type.total"
}

function HomeRankMenu:draw()
   self.win:draw()

   Ui.draw_topic("building.home.rank.value", self.x + 28, self.y + 36, self.t)
   Ui.draw_topic("building.home.rank.heirloom_rank", self.x + 28, self.y + 106, self.t)

   Draw.set_color(255, 255, 255, 50)
   self.bg:draw(
      self.x + self.width / 4,
      self.y + self.height / 2,
      self.width / 5 * 2,
      self.height - 80,
      nil,
      true)

   for i, header in ipairs(HEADERS) do
      local value
      if i == 1 then
         value = self.base_value
      elseif i == 2 then
         value = self.home_value
      elseif i == 3 then
         value = self.furniture_value
      else
         value = self.total_value
      end

      local x = self.x + 45 + math.floor((i-1) / 2) * 190
      local y = self.y + 68 + (i-1) % 2 * 18

      Draw.set_color(0, 0, 0)
      Draw.set_font(12) -- 12 + sizeFix
      Draw.text(I18N.get(header), x, y)

      Draw.set_font(14)
      local star_count = math.clamp(math.floor(value / 1000), 1, 10)
      for j = 1, star_count do
         -- TODO #143
         self.star:relayout(x + 35 + self.star_width * (j - 1), y - 2)
         self.star:draw()
      end
   end

   Draw.set_font(12) -- 12 + sizeFix
   Draw.set_color(0, 0, 0)

   self.chip_batch:clear()
   for i, entry in ipairs(self.data) do
      if i > 10 then
         break
      end

      local y_offset = (i-1) * 16

      self.chip_batch:add(entry.chip_id, self.x + 37, self.y + 138 + y_offset, nil, nil, entry.chip_color, true)
      Draw.text(entry.rank_text, self.x + 68, self.y + 138 + y_offset)
      Draw.text(entry.item_name, self.x + 110, self.y + 138 + y_offset)
   end
   self.chip_batch:draw()
end

function HomeRankMenu:update(dt)
   local canceled = self.canceled

   self.canceled = false

   if canceled then
      return nil, "canceled"
   end
end

function HomeRankMenu:release()
   self.chip_batch:release()
end

return HomeRankMenu
