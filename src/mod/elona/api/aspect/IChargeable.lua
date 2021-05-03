local IChargeable = class.interface("IChargeable",
                                    {
                                       charges = "number",
                                       max_charges = "number",
                                       can_be_recharged = "boolean",
                                       display_charge_count = "boolean"
                                    })

function IChargeable:init(item, params)
   if type(params.charges) == "function" then
      self.charges = params.charges(item)
   elseif type(params.charges) == "number" then
      self.charges = params.charges
   else
      self.charges = 0
   end
   self.max_charges = params.max_charges or 0
   self.can_be_recharged = params.can_be_recharged
   if self.can_be_recharged == nil then
      self.can_be_recharged = true
   end
   self.display_charge_count = params.display_charge_count
   if self.display_charge_count == nil then
      self.display_charge_count = true
   end
end

function IChargeable:is_charged(item)
   return self.charges > 0
end

function IChargeable:set_charges(item, charges)
   self.charges = math.max(charges, 0)
end

function IChargeable:modify_charges(item, delta)
   self:set_charges(item, self.charges + delta)
end

function IChargeable:is_rechargeable(item)
   return self:calc(item, "max_charges") > 0
      and self:calc(item, "can_be_recharged")
end

return IChargeable
