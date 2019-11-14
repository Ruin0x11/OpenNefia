local ILocalizable = require("api.ILocalizable")

local i18n = require("internal.i18n")

-- Interface to the text localization system.
-- @module I18N
local I18N = {}

function I18N.language()
   return "jp"
end

function I18N.quote_character()
   return "「"
end

function I18N.is_fullwidth()
   return true
end

function I18N.get(text, ...)
   local args = {}
   for i = 1, select("#", ...) do
      local arg = select(i, ...)
      if class.is_an(ILocalizable, arg) then
         args[i] = arg:produce_locale_data()
      else
         args[i] = arg
      end
   end
   return i18n.get(text, table.unpack(args))
end

function I18N.get_optional(key, ...)
   return key
end

return I18N
