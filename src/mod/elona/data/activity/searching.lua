local Material = require("mod.elona.api.Material")
local Gui = require("api.Gui")
local Feat = require("api.Feat")

data:add {
   _type = "base.activity",
   _id = "searching",
   elona_id = 105,

   params = { feat = "table", auto_turn_anim = "string" },

   default_turns = function(self)
      return (Feat.is_alive(self.feat) and self.feat.material_default_turns) or 20
   end,
   animation_wait = function(self)
      return (Feat.is_alive(self.feat) and self.feat.material_animation_wait) or 15
   end,
   auto_turn_anim = function(self)
      return (Feat.is_alive(self.feat) and self.feat.material_auto_turn_anim) or "base.searching"
   end,
   localize = function(self)
      return (Feat.is_alive(self.feat) and self.feat.material_activity_name) or "activity._.elona.searching.verb"
   end,

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:996 	if cRowAct(cc)=false{ ..
            if not Feat.is_alive(self.feat) then
               return "stop"
            end

            local on_start_text = self.feat.on_start_materials_text or "activity.dig_spot.start.other"
            Gui.mes(on_start_text)

            if self.feat.on_start_materials_sound then
               Gui.play_sound(self.feat.on_start_materials_sound, self.feat.x, self.feat.y)
            end
            -- <<<<<<<< shade2/proc.hsp:1002 		} ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1004 	if rowActRE!false:gosub *randomSite:return ..
            if not Feat.is_alive(self.feat) then
               params.chara:remove_activity()
               return "turn_end"
            end

            local finished = Material.dig_random_site(self.feat, params.chara)
            if finished then
               params.chara:remove_activity()
               return "turn_end"
            end
            if self.turns % 5 == 0 then
               local sound = self.feat.on_material_sound_text
               if sound then
                  Gui.mes_c(sound, "Blue")
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
            -- >>>>>>>> shade2/proc.hsp:56 		s=lang("もう何もない。","You can't find anything anymor ...
            local on_finish_text = self.feat.on_finish_materials_text or "activity.material.searching.no_more"
            Gui.mes(on_finish_text)
            -- <<<<<<<< shade2/proc.hsp:56 		s=lang("もう何もない。","You can't find anything anymor ..

            -- >>>>>>>> shade2/proc.hsp:1035:DONE 	spillFrag refX,refY,1 ..
            if Feat.is_alive(self.feat) then
               self.feat:remove_ownership()
            end
         end
         -- <<<<<<<< shade2/proc.hsp:1037 	return ..
      }
   }
}
