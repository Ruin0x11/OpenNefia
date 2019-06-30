local IFeat = require("api.feat.IFeat")
local IFactioned = require("api.IFactioned")

-- TODO: need an "acts_as" field to be able to use as "base.feat". But
-- also the original type should be accessible.
local ITrap = class.interface("ITrap", {}, IFactioned)

function ITrap:build()
   IFeat.build(self)

   IFactioned.init(self)
end

function ITrap:refresh()
   IFeat.refresh(self)

   self.is_solid = false
end

function ITrap:on_stepped_on(obj)
   if not obj:calc("is_floating") and self:reaction_towards(obj) < 0 then
      self:calc("on_activate", obj)
   end
end

return IFeat
