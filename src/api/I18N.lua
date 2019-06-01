local I18N = {}

function I18N.language()
   return "jp"
end

function I18N.is_fullwidth()
   return true
end

function I18N.get(key, ...)
   return key
end

return I18N
