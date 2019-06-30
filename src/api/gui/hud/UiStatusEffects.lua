local data = require("internal.data")
local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")
local UiTheme = require("api.gui.UiTheme")

local UiStatusEffects = class.class("UiStatusEffects", {ISettable, IUiElement})

function UiStatusEffects:init()
   self.indicators = {}
   self.max_width = 50
end

function UiStatusEffects:set_data(status_effects)
   self.indicators = {}

   for id, turns in pairs(status_effects) do
      local status_effect = data["base.status_effect"][id]
      assert(status_effect ~= nil)

      if type(status_effect.ui_indicator) == "table" then
         if turns > 0 then
            -- TODO: ordering
            self.indicators[#self.indicators + 1] = status_effect.ui_indicator
         end
      end
   end

   self:calc_max_width()
end

function UiStatusEffects:calc_max_width()
   self.max_width = 50
   Draw.set_font(self.t.indicator_font)
   for _, indicator in ipairs(self.indicators) do
      self.max_width = math.max(self.max_width, Draw.text_width(indicator.text) + 20)
   end
end

function UiStatusEffects:relayout(x, y, width, height)
   self.width = width
   self.height = math.min(#self.indicators * 20, height or 10000)
   self.x = x
   self.y = y - self.height
   self.t = UiTheme.load(self)

   self:calc_max_width()
end

function UiStatusEffects:draw()
   Draw.set_font(self.t.indicator_font)
   local y = self.y
   for _, indicator in ipairs(self.indicators) do
      self.t.status_effect_bar:draw(self.x, y, self.max_width)
      Draw.text(indicator.text,
                self.x + 6,
                y + 1, -- y + vfix + 1
                indicator.color)
      y = y + 20
   end
end

function UiStatusEffects:update()
end

return UiStatusEffects
