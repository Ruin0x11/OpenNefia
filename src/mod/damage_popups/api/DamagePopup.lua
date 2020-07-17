local Draw = require("api.Draw")

local DamagePopup = {}

local max = 20

function DamagePopup.install()
   Draw.register_draw_layer("mod.damage_popups.api.gui.DamagePopupLayer")
   save.damage_popups.popups = { count = 0 }
end

function DamagePopup.add(tx, ty, text, color, font)
   local popups = save.damage_popups.popups

   color = color or {255, 255, 255}
   font = font or 24

   if popups.count > max then
      -- TODO remove earliest
      return
   end

   popups[#popups + 1] = {
      x = tx,
      y = ty,
      text = text,
      color = color,
      shadow_color = {0, 0, 0, 255},
      font = font,
      frame = 0
   }
   popups.count = popups.count + 1
end

function DamagePopup.clear()
   local popups = save.damage_popups.popups
   table.replace_with(popups, { count = 0 })
end

function DamagePopup.on_hotload(old, new)
   DamagePopup.clear()
   table.replace_with(old, new)
end

return DamagePopup
