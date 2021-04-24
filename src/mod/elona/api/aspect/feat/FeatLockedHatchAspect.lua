local IFeatLockedHatch = require("mod.elona.api.aspect.feat.IFeatLockedHatch")

local FeatLockedHatchAspect = class.class("FeatLockedHatchAspect", IFeatLockedHatch)

function FeatLockedHatchAspect:init(item, params)
   self.feat_id = params.feat_id or "elona.stairs_down"
   self.sidequest_id = params.sidequest_id or "elona.main_quest"
   self.sidequest_flag = params.sidequest_flag or 0
   self.on_unlock_text = params.on_unlock_text or nil
   self.area_uid = params.area_uid
   self.area_floor = params.area_floor

   data["base.feat"]:ensure(self.feat_id)
   data["elona_sys.sidequest"]:ensure(self.sidequest_id)
end

return FeatLockedHatchAspect
