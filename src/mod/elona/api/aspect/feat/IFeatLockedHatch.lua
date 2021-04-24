local Gui = require("api.Gui")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Feat = require("api.Feat")
local IAspect = require("api.IAspect")
local IFeatDescendable = require("mod.elona.api.aspect.feat.IFeatDescendable")
local IFeatActivatable = require("mod.elona.api.aspect.feat.IFeatActivatable")

local IFeatLockedHatch = class.interface("IFeatLockedHatch",
                                        {
                                           sidequest_id = "string",
                                           sidequest_flag = "number",
                                           on_unlock_text = { type = "string", optional = true },
                                           feat_id = "string",
                                           area_uid = "number",
                                           area_floor = "number"
                                        }, { IAspect, IFeatDescendable, IFeatActivatable })


IFeatLockedHatch.default_impl = "mod.elona.api.aspect.feat.FeatLockedHatchAspect"

function IFeatLockedHatch:localize_action()
   return "base:aspect._.elona.IFeatLockedHatch.action_name"
end

function IFeatLockedHatch:can_unlock(feat, chara)
   return Sidequest.progress(self:calc(feat, "sidequest_id")) >= self:calc(feat, "sidequest_flag")
end

function IFeatLockedHatch:on_descend(feat, params)
   if self:can_unlock(feat, params.chara) then
      local text = self:calc(feat, "on_unlock_text")
      if text then
         Gui.mes(text)
      else
         Gui.mes("action.use_stairs.unlock.normal")
      end
      Gui.play_sound("base.chest1", feat.x, feat.y)

      -- TODO map entrance aspect
      local entrance = assert(Feat.create(self:calc(feat, "feat_id"), feat.x, feat.y, {force = true}, feat:current_map()))
      entrance.params.area_uid = self:calc(feat, "area_uid")
      entrance.params.area_floor = self:calc(feat, "area_floor")

      feat:remove_ownership()
   else
      Gui.play_sound("base.locked1", feat.x, feat.y)
      Gui.mes("action.use_stairs.locked")
   end

   return "turn_end"
end

function IFeatLockedHatch:on_activate(feat, params)
   return self:on_descend(feat, params)
end

return IFeatLockedHatch
