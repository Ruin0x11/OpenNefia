local ILocalizable  = class.interface("ILocalizable",
                                      {
                                         produce_locale_data = "function"
                                      })

--- Produces the data used to localize this object.
function ILocalizable:produce_locale_data()
   return {}
end

return ILocalizable
