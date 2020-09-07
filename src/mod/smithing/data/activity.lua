local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Smithing = require("mod.smithing.api.Smithing")
local Effect = require("mod.elona.api.Effect")

data:add {
   _type = "base.activity",
   _id = "upgrade_hammer",

   params = { hammer = "table" },
   default_turns = Smithing.calc_hammer_activity_turns,

   animation_wait = 20,

   on_interrupt = "prompt",

   on_start = function(self, params)
   end,

   on_pass_turns = function(self, params)
      local chara = params.chara
      if self.turns % 6 == 0 then
         if not Effect.do_stamina_check(chara, 2) then
            Gui.mes("magic.common.too_exhausted")
            chara:remove_activity()
            return "turn_end"
         end
      end

      if self.turns > 0 then
         if Rand.one_in(3) then
            Gui.mes_c("smithing.blacksmith_hammer.sound", "Blue")
         end
      end

      return "turn_end"
   end,

   on_finish = function(self, params)
      Smithing.upgrade_hammer(self.hammer, self.chara)
   end
}

data:add {
   _type = "base.activity",
   _id = "create_item",

   params = { hammer = "table", extend = "number", categories = "table", target_item = "table", material_item = "table" },
   default_turns = Smithing.calc_hammer_activity_turns,

   animation_wait = 20,

   on_interrupt = "prompt",

   on_start = function(self, params)
      self.extend = self.extend or 0
   end,

   on_pass_turns = function(self, params)
      local chara = params.chara
      if self.turns % 6 == 0 then
         if not Effect.do_stamina_check(chara, 2) then
            Gui.mes("magic.common.too_exhausted")
            chara:remove_activity()
            return "turn_end"
         end
      end

      if self.turns > 0 then
         if Rand.one_in(3) then
            Gui.mes_c("smithing.blacksmith_hammer.sound", "Blue")
         end
      end

      if Rand.one_in(Smithing.calc_smith_extend_chance(self.hammer, self.extend)) then
         self.extend = self.extend + Rand.rnd(3)
      end

      return "turn_end"
   end,

   on_finish = function(self, params)
      Smithing.create_item(self.hammer, params.chara, self.target_item, self.material_item, self.categories, self.extend)
   end
}
