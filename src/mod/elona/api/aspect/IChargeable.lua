local IChargeable = class.interface("IChargeable", { charges = "number", max_charges = "number" })

function IChargeable:is_charged(item)
   return self.charges > 0
end

return IChargeable
