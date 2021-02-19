local IFeat = require("api.feat.IFeat")
local IFactioned = require("api.IFactioned")
local Enum = require("api.Enum")

local ITrap = class.interface("ITrap", {}, {IFeat, IFactioned})

function ITrap:build()
   IFeat.build(self)

   IFactioned.init(self)
end

function ITrap:refresh()
   IFeat.refresh(self)

   self.is_solid = false
end

function ITrap:on_stepped_on(obj)
   if not obj:calc("is_floating") and self:relation_towards(obj) <= Enum.Relation.Enemy then
      self:emit("elona_sys.on_feat_activate", obj)
   end
end

return ITrap
