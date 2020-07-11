local Item = require("api.Item")
local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Rand = require("api.Rand")

data:add {
   _id = "pickpocket",
   _type = "elona_sys.magic",
   elona_id = 300,

   type = "skill",
   params = {
      "source",
      "target",
   },

   related_skill = "elona.stat_dexterity",
   cost = 20,
   range = 8000,

   cast = function(self, params)
      -- TODO
      if false then
         Gui.mes("magic.steal.in_quest")
         return false
      end

      local source = params.source
      if source:is_player() and not Effect.do_stamina_check(source, self) then
         return true
      end

      Input.query_inventory(source, "elona.inv_steal", {target=params.target})

      return true
   end
}

data:add {
   _id = "riding",
   _type = "elona_sys.magic",
   elona_id = 301,

   type = "skill",
   params = {
      "source",
      "target",
   },

   related_skill = "elona.stat_will",
   cost = 20,
   range = 8000,

   cast = function(self, params)
      -- TODO
      return true
   end
}

data:add {
   _id = "performer",
   _type = "elona_sys.magic",
   elona_id = 183,

   type = "skill",
   params = {
      "source",
      "target",
   },

   related_skill = "elona.stat_charisma",
   cost = 25,
   range = 10000,

   cast = function(self, params)
      local source = params.source
      if not source:is_player() then
         local found = false
         for _, i in source:iter_items() do
            if Item.is_alive(i) and i.skill == "elona.performer" then
               params.item = i
               found = true
               break
            end
         end
         if not found then
            return false
         end
      end

      if not source:has_skill("elona.performer") then
         if source:is_in_fov() then
            Gui.mes("magic.perform.do_not_know", source)
         end
         return false
      end

      if source:is_player() and not Effect.do_stamina_check(source, self) then
         return true
      end

      source:start_activity("elona.performer")

      return true
   end
}

local function cook(chara, item, cooking_tool)
   Gui.play_sound("base.cook1")
   local cooking = chara:skill_level("elona.cooking")

   local food_quality = Rand.rnd(cooking + 7) + Rand.rnd
end

data:add {
   _id = "cooking",
   _type = "elona_sys.magic",
   elona_id = 184,

   type = "skill",
   params = {
      "source",
      "item",
   },

   related_skill = "elona.stat_learning",
   cost = 15,
   range = 10000,

   cast = function(self, params)
      local source = params.source
      if not source:has_skill("elona.cooking") then
         Gui.mes("magic.cook.do_not_know")
         return false
      end

      local item, canceled = Input.query_item(source, "elona.inv_cook")
      if canceled then
         return false
      end

      if source:is_player() and not Effect.do_stamina_check(source, self) then
         return true
      end

      cook(source, item, params.item)

      return true
   end
}
