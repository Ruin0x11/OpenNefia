local Gui = require("api.Gui")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local Smithing = require("mod.smithing.api.Smithing")

data:add {
   _type = "base.item",
   _id = "blacksmith_hammer",
   custom_author = "名も知れぬ鍛冶屋",

   image = "smithing.blacksmith_hammer",
   level = 1,
   rarity = 1000000,
   value = 75,
   weight = 5000,
   tags = { "nodownload" },
   categories = { "elona.misc_item" },

   params = {
      hammer_level = 1,      -- iParam1(ci)
      hammer_experience = 0, -- iParam2(ci)
      hammer_total_uses = 0  -- iParam3(ci)
   },

   on_use = function(self, params)
      if not params.chara:is_player() then
         Gui.mes("common.nothing_happens")
         return false
      end
      Smithing.on_use_blacksmith_hammer(self, params.chara)
   end,

   events = {
      {
         id = "base.on_item_build_description",
         name = "Add hammer information",

         callback = function(item, params, result)
            if item:calc("identify_state") >= Enum.IdentifyState.Quality then
               local exp_perc = (item.params.hammer_experience * 100.0) / Smithing.calc_hammer_required_exp(item)
               exp_perc = ("%3.6f"):format(exp_perc):sub(1, 6)
               local text = ("[Lv: %d Exp: %s%%]"):format(item.params.hammer_level, string.right_pad(tostring(exp_perc), 6))
               table.insert(result, { text = text, icon = 7 })
            end
         end
      }
   }
}
