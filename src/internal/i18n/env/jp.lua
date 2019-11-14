local i18n = require("internal.i18n")

local jp = {}

function jp.you()
   return i18n.get("chara.you")
end

function jp.name(obj)
   if obj.is_player then
      return jp.you()
   end

   if type(obj) == "table" then
      return obj.name or i18n.get("chara.something")
   end

   return i18n.get("chara.something")
end

function jp.basename(obj)
   if type(obj) == "table" then
      return obj.basename or obj.name or i18n.get("chara.something")
   end

   return i18n.get("chara.something")
end

jp.itemname = jp.name
jp.itembasename = jp.basename

function jp.ordinal(n)
   return tostring(n)
end

function jp.he(obj)
   if not type(obj) == "table" then
      return "彼"
   end

   if obj.gender == "male" then
      return "彼"
   else
      return "彼女"
   end
end

function jp.his(obj)
   if not type(obj) == "table" then
      return "彼の"
   end

   if obj.is_player then
      return "あなたの"
   elseif obj.gender == "male" then
      return "彼の"
   else
      return "彼女の"
   end
end

function jp.him(obj)
   if not type(obj) == "table" then
      return "彼"
   end

   if obj.gender == "male" then
      return "彼"
   else
      return "彼女"
   end
end

function jp.kare_wa(obj)
   if not type(obj) == "table" then
      return "それは"
   end

   if obj.is_player then
      return ""
   elseif not obj.is_visible then
      return "それは"
   else
      return obj.name .. "は"
   end
end

return jp
