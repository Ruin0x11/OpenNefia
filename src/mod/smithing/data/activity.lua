local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Smithing = require("mod.smithing.api.Smithing")
local Effect = require("mod.elona.api.Effect")
local Input = require("api.Input")
local Item = require("api.Item")
local Prompt = require("api.gui.Prompt")

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
      Smithing.upgrade_hammer(self.params.hammer, params.chara)
   end
}

data:add {
   _type = "base.activity",
   _id = "create_equipment",

   params = { hammer = "table", extend = "number", categories = "table", target_item = "table", material_item = "table", infinite = "boolean" },
   default_turns = Smithing.calc_hammer_activity_turns,

   animation_wait = 20,

   on_interrupt = "prompt",

   on_start = function(self, params)
      self.params.extend = self.params.extend or 0
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

      if Rand.one_in(Smithing.calc_smith_extend_chance(self.params.hammer, self.params.extend)) then
         self.params.extend = self.params.extend + Rand.rnd(3)
      end

      return "turn_end"
   end,

   on_finish = function(self, params)
      Smithing.create_equipment(self.params.hammer, params.chara, self.params.target_item, self.params.material_item, self.params.categories, self.params.extend)

      -- >>>>>>>> oomSEST/src/hammer.hsp:596 		if (hmrepeat != 2) { ...
      local do_repeat
      local infinite = self.params.infinite
      if infinite then
         do_repeat = true
      else
         Gui.mes("smithing.blacksmith_hammer.create.again.prompt")
         Gui.update_screen()
         local choices = {
            { text = "ui.yes", key = "y" },
            { text = "ui.no",  key = "n" }
         }
         if self.params.hammer.bonus >= 7 then
            choices[#choices+1] = { text = "smithing.blacksmith_hammer.create.again.choices.infinity", key = "h" }
         end
         local res = Prompt:new(choices):query()
         do_repeat = res.index == 1 or res.index == 3
         infinite = res.index == 3
      end

      if do_repeat then
         local proceed = true

         local new_target = params.chara:find_item(self.params.target_item._id)
         if not Item.is_alive(new_target) then
            proceed = false
         end
         local new_material
         if self.params.material_item then
            new_material = params.chara:find_item(self.params.material_item._id)
            if not Item.is_alive(new_material) then
               proceed = false
            end
         end

         if proceed then
            params.chara:start_activity("smithing.create_equipment", {hammer=self.params.hammer, categories=self.params.categories, target_item=new_target, material_item=new_material, infinite=infinite})
         else
            Gui.mes("smithing.blacksmith_hammer.create.again.insufficent_material")
         end
      end
      -- <<<<<<<< oomSEST/src/hammer.hsp:660 		} ..
   end
}

data:add {
   _type = "base.activity",
   _id = "repair_furniture",

   params = { hammer = "table", target_item = "table", material_item = "table" },
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
      Smithing.repair_furniture(self.params.hammer, params.chara, self.params.target_item, self.params.material_item)
   end
}

data:add {
   _type = "base.activity",
   _id = "repair_equipment",

   params = { hammer = "table", target_item = "table", power = "number" },
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
      Smithing.repair_equipment(self.params.hammer, params.chara, self.params.target_item, self.params.power)
   end
}
