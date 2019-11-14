local i18n = require("internal.i18n")

local en = {}

function en.you()
   return i18n.get("chara.you")
end

function en.name(obj)
   if type(obj) == "table" then
      if obj.is_player then
         return en.you()
      end

      local name = obj.name or i18n.get("chara.something")
      local first = name:sub(1, 1)
      if first == "\"" or first == "<" then
         return name
      elseif not obj.has_own_name then
         return "the " .. name
      end
   end

   return i18n.get("chara.something")
end

function en.basename(obj)
   if type(obj) == "table" then
      return obj.basename or obj.name or i18n.get("chara.something")
   end

   return i18n.get("chara.something")
end

function en.itemname(obj)
   if type(obj) == "table" then
      return obj.name or i18n.get("chara.something")
   end

   return i18n.get("chara.something")
end

en.itembasename = en.basename

function en.ordinal(n)
   if n % 10 == 1 and n ~= 11 then
      return tostring(n) .. "st"
   elseif n % 10 == 2 and n ~= 12 then
      return tostring(n) .. "nd"
   elseif n % 10 == 3 and n ~= 13 then
      return tostring(n) .. "rd"
   else
      return tostring(n) .. "th"
   end
end

function en.he(obj)
   if type(obj) == "table" then
      if obj.gender == "male" then
         return "he"
      elseif obj.gender == "female" then
         return "she"
      else
         return "it"
      end
   end

   return "its"
end

function en.his(obj)
   if type(obj) == "table" then
      if obj.gender == "male" then
         return "his"
      elseif obj.gender == "female" then
         return "her"
      else
         return "its"
      end
   end

   return "its"
end

function en.s(obj, need_e)
   if type(obj) == "number" then
      if obj > 1 then
         return ""
      else
         return "s"
      end
   elseif type(obj) == "table" then
      if obj.amount then
         if obj.amount > 1 then
            return ""
         else
            return "s"
         end
      end

      if obj.is_player then
         return ""
      elseif need_e then
         return "es"
      else
         return "s"
      end
   end

   return "s"
end

function en.is(obj)
   if type(obj) == "number" then
      if obj > 1 then
         return "are"
      end
   elseif type(obj) == "table" then
      if obj.amount then
         if obj.amount > 1 then
            return ""
         else
            return "s"
         end
      end

      if obj.is_player then
         return "are"
      end
   end

   return "is"
end

function en.have(obj)
   if type(obj) == "table" then
      if obj.is_player then
         return "have"
      end
   end

   return "has"
end

function en.does(obj)
   local n = obj
   if type(obj) == "table" and obj.amount then
      n = obj.amount
   end

   if n == 1 then
      return "do"
   end

   return "does"
end

function en.he(obj, ignore_sight)
   if type(obj) ~= "table" then
      return "it"
   end

   if ignore_sight then
      if obj.gender == "male" then
         return "he"
      elseif obj.gender == "female" then
         return "she"
      else
         return "it"
      end
   end

   if not obj.is_visible then
      return "it"
   end

   if obj.is_player then
      return "you"
   elseif obj.gender == "male" then
      return "he"
   elseif obj.gender == "female" then
      return "she"
   end

   return "it"
end

function en.his(obj, ignore_sight)
   if type(obj) ~= "table" then
      return "its"
   end

   if ignore_sight then
      if obj.gender == "male" then
         return "his"
      elseif obj.gender == "female" then
         return "hers"
      else
         return "its"
      end
   end

   if not obj.is_visible then
      return "its"
   end

   if obj.is_player then
      return "your"
   elseif obj.gender == "male" then
      return "his"
   elseif obj.gender == "female" then
      return "her"
   end

   return "its"
end

function en.him(obj, ignore_sight)
   if type(obj) ~= "table" then
      return "it"
   end

   if ignore_sight then
      if obj.gender == "male" then
         return "him"
      elseif obj.gender == "female" then
         return "her"
      else
         return "it"
      end
   end

   if not obj.is_visible then
      return "it"
   end

   if obj.is_player then
      return "yourself"
   elseif obj.gender == "male" then
      return "him"
   elseif obj.gender == "female" then
      return "her"
   end

   return "it"
end

function en.his_owned(obj)
   if type(obj) == "table" then
      if obj.is_player then
         return "r"
      end
   end

   return "'s"
end

function en.himself(obj)
   if type(obj) == "table" then
      if not obj.is_visible then
         return "itself"
      end
      if obj.is_player then
         return "yourself"
      elseif obj.gender == "male" then
         return "himself"
      elseif obj.gender == "female" then
         return "herself"
      end
   end

   return "itself"
end

function en.trim_job(name_with_job)
   return string.gsub(name_with_job, " .*", " ")
end

function en.name_nojob(obj)
   return en.trim_job(en.name(obj))
end

function en.capitalize(str)
   if str == "" then
      return str
   end

   return str:gsub("^%l", string.upper)
end

return en
