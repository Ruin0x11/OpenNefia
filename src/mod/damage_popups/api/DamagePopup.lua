local Draw = require("api.Draw")

local DamagePopup = {}

local max = 200

local g_popups = require("mod.damage_popups.g_popups")

function DamagePopup.install()
   Draw.register_draw_layer("mod.damage_popups.api.gui.DamagePopupLayer")
end

function DamagePopup.add(tx, ty, text, color, font)
   color = color or {255, 255, 255}
   font = font or 24

   g_popups[#g_popups + 1] = {
      x = tx,
      y = ty,
      text = text,
      color = color,
      font = font,
      frame = 0
   }
end

function DamagePopup.clear()
   g_popups = {}
end

return DamagePopup
