local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local data = require("internal.data")

local UiBuffs = class.class("UiBuffs", { IUiWidget, ISettable })

function UiBuffs:init()
   self.buffs = {}
end

function UiBuffs:default_widget_position(x, y, width, height)
   return width - 40, height - (72 + 16) - 40
end

function UiBuffs:default_widget_refresh(player)
   self:set_data(player)
end

function UiBuffs:default_widget_z_order()
   return 75000
end

function UiBuffs:set_data(player)
   self.buffs = {}
   for _, buff in ipairs(player.buffs) do
      if buff.duration > 0 then
         local buff_data = data["elona_sys.buff"]:ensure(buff._id)
         self.buffs[#self.buffs+1] = { image = buff_data.image or 0, duration = tostring(buff.duration) }
      end
   end
   self.height = #self.buffs * 32
end

function UiBuffs:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function UiBuffs:draw()
   Draw.set_font(12)

   for i, buff in ipairs(self.buffs) do
      local y = self.y - i * 32
      Draw.set_color(255, 255, 255)
      self.t.base.buff_icons:draw_region(buff.image + 1, self.x, y)
      Draw.set_color(0, 0, 0)
      Draw.text(buff.duration, self.x + 3, y + 19)
      Draw.set_color(255, 255, 255)
      Draw.text(buff.duration, self.x + 2, y + 18)
      y = y - 32
   end
end

function UiBuffs:update()
end

return UiBuffs
