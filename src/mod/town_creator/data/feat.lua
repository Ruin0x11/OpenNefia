local Gui = require("api.Gui")
local Input = require("api.Input")
local TownCreator = require("mod.town_creator.api.TownCreator")

data:add {
   _type = "base.feat",
   _id = "politics_board",
   image = "elona.feat_politics_board",
   is_solid = true,
   is_opaque = false,
   on_bumped_into = function(self, params)
      Gui.play_sound("base.chat")
      local choice = Input.prompt {
         "mod.town_creator.build",
         "mod.town_creator.politics"
      }

      if choice.index == 1 then
      elseif choice.index == 2 then
         return data["base.feat"]["elona.politics_board"]:on_bumped_into(params)
      end
   end,
   params = {},
   events = {}
}
