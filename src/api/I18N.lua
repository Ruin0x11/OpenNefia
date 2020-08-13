local Event = require("api.Event")
-- Interface to the text localization system.
-- @module I18N

local ILocalizable = require("api.ILocalizable")

local i18n = require("internal.i18n")

local I18N = {}

--- Returns the current language identifier as a string.
---
--- @treturn string
function I18N.language()
   return i18n.language
end

--- Returns the current language ID.
---
--- @treturn string
function I18N.language_id()
   return i18n.language_id
end

--- @treturn string
function I18N.quote_character()
   return "「"
end

--- @treturn string
function I18N.space()
   if I18N.is_fullwidth() then
      return ""
   end

   return " "
end

--- True if the current language uses fullwidth characters.
---
--- @treturn bool
function I18N.is_fullwidth()
   return I18N.language() == "jp"
end

--- @function I18N.capitalize(str)
--- @tparam string str
--- @treturn string
I18N.capitalize = i18n.capitalize

--- Localizes a string with arguments. Pass the ID of a localized
--- string and any arguments to its formatting function. May return
--- nil if the ID was not found.
---
--- If any of the arguments implement ILocalizable, then the
--- localization data for them will be produced and sent instead.
---
--- @tparam string id ID of the localized string
--- @tparam ... ... Extra arguments to pass to the formatter.
--- @treturn[opt] string The localized text
--- @see ILocalizable
function I18N.get_optional(text, ...)
   local args = {}
   for i = 1, select("#", ...) do
      local arg = select(i, ...)
      local i18n = require("internal.i18n.init")
      if class.is_an(ILocalizable, arg) then
         args[i] = arg:produce_locale_data()
      else
         args[i] = I18N.get_optional(arg) or arg
      end
   end

   local result = i18n.get(text, table.unpack(args))

   result = Event.trigger("base.after_get_translation", { language_id = i18n.language_id, id = text, args = args }, result)

   return result
end

--- Localizes a string with arguments. Pass the ID of a localized
--- string and any arguments to its formatting function. May return
--- nil if the ID was not found.
---
--- If any of the arguments implement ILocalizable, then the
--- localization data for them will be produced and sent instead.
---
--- @tparam string id ID of the localized string
--- @param ... Extra arguments to pass to the formatter.
--- @treturn string The localized text
--- @see ILocalizable
function I18N.get(text, ...)
   return I18N.get_optional(text, ...) or ("<error: %s>"):format(text)
end


-- TODO for itemname, provide a set of "cut points" so the user can
-- split the string and insert whatever.

--- Switches the current language.
---
--- @tparam string lang Language identifier.
--- @function switch_language
I18N.switch_language = i18n.switch_language

function I18N.get_choice_count(prefix, suffix)
   local i = 1

   if suffix then
      suffix = "." .. suffix
   else
      suffix = ""
   end

   while I18N.get_optional(prefix .. "._" .. i .. suffix) do
      i = i + 1
   end

   return i - 1
end

function I18N.quote_speech(id, ...)
   local text = I18N.get_optional(id, ...) or id

   -- TODO
   if not I18N.is_fullwidth() then
      text = ("\"%s\""):format(text)
   end

   return text
end

return I18N
