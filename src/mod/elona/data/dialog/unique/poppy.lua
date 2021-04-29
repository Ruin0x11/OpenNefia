local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")

data:add {
   _type = "elona_sys.dialog",
   _id = "poppy",

   root = "talk.unique.poppy",
   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.puppys_cave")
         if flag == 1000 then
            return "quest_completed"
         end

         return "find"
      end,
      find = {
         text = {
            {"find.dialog"},
         },
         choices = function()
            local choices = {}
            if Chara.player():can_recruit_allies() then
               table.insert(choices, {"take", "find.choices.take"})
            end
            table.insert(choices, {"__END__", "ui.bye"})

            return choices
         end
      },
      take = function(t)
         Gui.mes("talk.unique.poppy.find.you_must_return", t.speaker)
         Chara.player():recruit_as_ally(t.speaker)
         t.speaker.is_being_escorted_poppy = true
         t.speaker:refresh()

         return "__END__"
      end,
      quest_completed = {
         text = {
            {"complete"},
         }
      }
   }
}

local function check_poppy_killed(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1680 			if cBit(cGuardTemp,tc)=true{ ...
   if chara:is_player() or not chara:is_in_player_party() then
      return
   end

   if chara.is_being_escorted_poppy then
      chara.state = "Dead"
   end
   -- <<<<<<<< shade2/chara_func.hsp:1682 				} ..
end
