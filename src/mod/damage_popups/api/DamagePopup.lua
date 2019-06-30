local Draw = require("api.Draw")

local DamagePopup = {}

local max = 20

local g_popups = require("mod.damage_popups.g_popups")

function DamagePopup.install()
   Draw.register_draw_layer("mod.damage_popups.api.gui.DamagePopupLayer")
end

function DamagePopup.add(tx, ty, text, color, font)
   color = color or {255, 255, 255}
   font = font or 24

   if g_popups.count > max then
      -- TODO remove earliest
      return
   end

   g_popups[#g_popups + 1] = {
      x = tx,
      y = ty,
      text = text,
      color = color,
      font = font,
      frame = 0
   }
   g_popups.count = g_popups.count + 1
end

function DamagePopup.clear()
   table.replace_with(g_popups, { count = 0 })
end

function DamagePopup.on_hotload(old, new)
   DamagePopup.clear()
   table.replace_with(old, new)
end

return DamagePopup
