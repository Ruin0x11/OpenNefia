local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Event = require("api.Event")
local Log = require("api.Log")

local EmotionIcon = {}

local function on_proc_status_effect(p)
   if p.status_effect.emotion_icon ~= nil then
      EmotionIcon.set(p.victim, p.status_effect.emotion_icon, 1)
   end
end

local function update_emotion_icon(p)
   if type(p.chara.emotion_icon) == "table" then
      p.chara.emotion_icon.turns = p.chara.emotion_icon.turns - 1
      if p.chara.emotion_icon.turns <= 0 then
         p.chara.emotion_icon = nil
      end
   end
end

function EmotionIcon.install(ui_theme)
   Draw.register_draw_layer("mod.emotion_icons.api.gui.EmotionIconLayer")

   local tab = data["base.ui_theme"][ui_theme].items
   local icons = {}
   for k, v in data["base.emotion_icon"]:iter() do -- HACK
      icons[k] = v.image
   end
   tab["mod.emotion_icons.api.gui.EmotionIconLayer"] = icons

   Event.register("base.on_proc_status_effect", "status effect emoicon", on_proc_status_effect)
   Event.register("base.before_chara_turn_start", "emoicon turn decay", update_emotion_icon)
end

function EmotionIcon.set(chara, id, turns)
   if not Chara.is_alive(chara) then
      return
   end

   if not data["base.emotion_icon"][id] then
      Log.warn("Unknown emotion_icon %s", id)
      return
   end

   if id == nil then
      chara.emotion_icon = nil
   else
      turns = turns or 10
      chara.emotion_icon = { turns = turns, id = id }
   end
end

function EmotionIcon.clear_all()
   for _, c in Map.iter_charas() do
      EmotionIcon.set(chara, nil)
   end
end

return EmotionIcon
