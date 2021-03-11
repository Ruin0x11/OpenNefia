local Material = require("mod.elona.api.Material")
local Gui = require("api.Gui")
local Feat = require("api.Feat")

local function try_get_spot_info(feat, property)
   if Feat.is_alive(feat) then
      local mat_spot_info = feat.params.material_spot_info
      if mat_spot_info then
         local info = data["elona.material_spot_feat_info"]:ensure(mat_spot_info)
         if info[property] then
            return info[property]
         end
      end
   end
   return nil
end

data:add {
   _type = "base.activity",
   _id = "searching",
   elona_id = 105,

   params = { feat = "table", no_more_materials = "boolean" },

   default_turns = function(self)
      return try_get_spot_info(self.params.feat, "activity_default_turns") or 20
   end,
   animation_wait = function(self)
      return try_get_spot_info(self.params.feat, "activity_animation_wait") or 15
   end,
   auto_turn_anim = function(self)
      return try_get_spot_info(self.params.feat, "activity_auto_turn_anim") or "base.searching"
   end,
   localize = function(self)
      return try_get_spot_info(self.params.feat, "activity_name") or "activity._.elona.searching.verb"
   end,

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:996 	if cRowAct(cc)=false{ ..
            self.params.no_more_materials = false

            if not Feat.is_alive(self.params.feat) then
               return "stop"
            end

            local on_start_text = try_get_spot_info(self.params.feat, "on_start_gather_text") or "activity.dig_spot.start.other"
            Gui.mes(on_start_text)

            local on_start_sound = try_get_spot_info(self.params.feat, "on_start_gather_sound")
            if on_start_sound then
               Gui.play_sound(on_start_sound, self.params.feat.x, self.params.feat.y)
            end
            -- <<<<<<<< shade2/proc.hsp:1002 		} ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1004 	if rowActRE!false:gosub *randomSite:return ..
            if not Feat.is_alive(self.params.feat) then
               params.chara:remove_activity()
               return "turn_end"
            end

            local finished = Material.dig_random_site(params.chara, self.params.feat)
            if finished then
               self.params.no_more_materials = true
            end

            if self.params.no_more_materials then
               -- HACK We need to run the "finish" callback the next turn, so
               -- set turns to 0.
               self.turns = 0
               return "turn_end"
            end

            if self.turns % 5 == 0 then
               local sound_text = try_get_spot_info(self.params.feat, "on_gather_sound_text")
               if sound_text then
                  Gui.mes_c(sound_text, "Blue")
               end
            end
            return "turn_end"
            -- <<<<<<<< shade2/proc.hsp:1009 		} ..
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1035: 	spillFrag refX,refY,1 ..
            if self.params.no_more_materials then
               local on_finish_text = try_get_spot_info(self.params.feat, "on_gather_no_more_text") or "activity.material.searching.no_more"
               Gui.mes(on_finish_text)
               if Feat.is_alive(self.params.feat) then
                  self.params.feat:remove_ownership()
               end
            end
            -- <<<<<<<< shade2/proc.hsp:1037 	return ..
         end
      }
   }
}
