local Gui = require("api.Gui")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Feat = require("api.Feat")

local IFeatLockedDoor = class.interface("IFeatLockedDoor",
                                        {
                                           sidequest_id = "string",
                                           sidequest_flag = "number",
                                           on_unlock_text = { type = "string", optional = true },
                                           feat_id = "string",
                                           area_uid = "number",
                                           area_floor = "number"
                                        })

function IFeatLockedDoor:localize_action()
   return "base:aspect._.elona.IFeatLockedDoor.action_name"
end

function IFeatLockedDoor:can_unlock(feat, chara)
   return Sidequest.progress(self:calc(feat, "sidequest_id")) >= self:calc(feat, "sidequest_flag")
end

function IFeatLockedDoor:on_descend(feat, params)
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

function IFeatLockedDoor:on_activate(feat, params)
   return self:on_descend(feat, params)
end

return IFeatLockedDoor
