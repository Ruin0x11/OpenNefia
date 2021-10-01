local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local ICharaElonaFlags = require("mod.elona.api.aspect.chara.ICharaElonaFlags")

data:add {
   _type = "elona_sys.dialog",
   _id = "poppy",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.puppys_cave")
         if flag == 1000 then
            return "quest_completed"
         end

         return "find"
      end,
      find = {
         text = "talk.unique.poppy.find.dialog",
         choices = function()
            local choices = {}
            if Chara.player():can_recruit_allies() then
               table.insert(choices, {"take", "talk.unique.poppy.find.choices.take"})
            end
            table.insert(choices, {"__END__", "ui.bye"})

            return choices
         end
      },
      take = function(t)
         Gui.mes("talk.unique.poppy.find.you_must_return", t.speaker)
         Chara.player():recruit_as_ally(t.speaker)
         local aspect = t.speaker:get_aspect_or_default(ICharaElonaFlags)
         aspect.is_being_escorted_sidequest = true
         t.speaker:refresh()

         return "__END__"
      end,
      quest_completed = {
         text = "talk.unique.poppy.complete",
      }
   }
}
