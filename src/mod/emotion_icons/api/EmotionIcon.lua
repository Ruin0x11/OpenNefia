local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Log = require("api.Log")

local EmotionIcon = {}

function EmotionIcon.install(ui_theme)
   Draw.register_draw_layer("mod.emotion_icons.api.gui.EmotionIconLayer")

   local tab = data["base.ui_theme"][ui_theme].items
   local icons = {}
   for k, v in data["base.emotion_icon"]:iter() do -- HACK
      icons[k] = v.image
   end
   tab["mod.emotion_icons.api.gui.EmotionIconLayer"] = icons
end

function EmotionIcon.set(chara, id)
   if not Chara.is_alive(chara) then
      return
   end

   if not data["base.emotion_icon"][id] then
      Log.warn("Unknown emotion_icon %s", id)
      return
   end

   chara.emotion_icon = id
end

function EmotionIcon.clear_all()
   for _, c in Map.iter_charas() do
      EmotionIcon.set(chara, nil)
   end
end

return EmotionIcon
