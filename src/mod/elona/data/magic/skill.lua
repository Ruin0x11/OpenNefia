local Item = require("api.Item")
local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Input = require("api.Input")
local Quest = require("mod.elona_sys.api.Quest")
local elona_Item = require("mod.elona.api.Item")
local Skill = require("mod.elona_sys.api.Skill")

data:add {
   _id = "performer",
   _type = "base.skill",
   elona_id = 183,

   type = "skill_action",
   effect_id = "elona.performer",
   related_skill = "elona.stat_charisma",
   range = 0,
   target_type = "self"
}

data:add {
   _id = "performer",
   _type = "elona_sys.magic",
   elona_id = 183,

   type = "skill",
   params = {
      "source",
   },
   cost = 25,

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

      if source:is_player() and not Effect.do_stamina_check(source, self.cost) then
         Gui.mes("magic.common.too_exhausted")
         return true
      end

      source:start_activity("elona.performing", {instrument = params.item})

      return true
   end
}

-- >>>>>>>> shade2/item.hsp:813 *item_cook ...
local function cook(chara, item, cooking_tool)
   Gui.play_sound("base.cook1")
   local cooking = chara:skill_level("elona.cooking")

   local item = item:separate()
   local name = item:build_name()

   local food_quality = math.min(Rand.rnd(cooking + 6) + Rand.rnd(cooking_tool.params.cooking_quality/50+1, math.floor(cooking / 5 + 7)))
   food_quality = Rand.rnd(food_quality + 1)
   if food_quality > 3 then
      food_quality = Rand.rnd(food_quality)
   end
   if cooking >= 5 and food_quality < 3 and Rand.one_in(4) then
      food_quality = 3
   end
   if cooking >= 10 and food_quality < 3 and Rand.one_in(3) then
      food_quality = 3
   end
   food_quality = math.clamp(math.floor(food_quality + cooking_tool.params.cooking_quality/100), 1, 9)

   Effect.make_dish(item, food_quality)

   Gui.mes("food.cook", name, cooking_tool:build_name(1), item:build_name(1))
   if item.params.food_quality > 2 then
      Skill.gain_skill_exp(chara, "elona.cooking", 30 + item.params.food_quality * 5)
   end
   chara:refresh_weight()
end
-- <<<<<<<< shade2/item.hsp:833 	return ..

data:add {
   _id = "cooking",
   _type = "base.skill",
   elona_id = 184,

   type = "skill_action",
   effect_id = "elona.cooking",
   related_skill = "elona.stat_learning",
   target_type = "self",
}

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

      local result, canceled = Input.query_item(source, "elona.inv_cook")
      if canceled then
         return false
      end

      local item = result.result

      if source:is_player() and not Effect.do_stamina_check(source, self.cost) then
         Gui.mes("magic.common.too_exhausted")
         return true
      end

      cook(source, item, params.item)

      return true
   end
}

data:add {
   _id = "fishing",
   _type = "base.skill",
   elona_id = 185,

   type = "skill_action",
   effect_id = "elona.fishing",
   related_skill = "elona.stat_perception",
   target_type = "self",
}

data:add {
   _id = "fishing",
   _type = "elona_sys.magic",
   elona_id = 185,

   type = "skill",
   params = {
      "source",
      "target",
   },
   cost = 5,

   cast = function(self, params)
      Gui.mes("TODO")

      return true
   end
}

data:add {
   _id = "pickpocket",
   _type = "base.skill",
   elona_id = 300,

   type = "skill_action",
   effect_id = "elona.pickpocket",
   related_skill = "elona.stat_dexterity",
   target_type = "nearby",
   ignore_missing_target = true
}

local function quest_prevents_stealing()
   local quest = Quest.get_immediate_quest()
   if quest == nil then
      return false
   end
   local quest_proto = data["elona_sys.quest"]:ensure(quest._id)
   return quest_proto.prevents_pickpocket
end

data:add {
   _id = "pickpocket",
   _type = "elona_sys.magic",
   elona_id = 300,

   type = "skill",
   params = {
      "source",
      -- "target", optional
      "x",
      "y",
   },

   related_skill = "elona.stat_dexterity",
   cost = 20,
   range = 8000,

   cast = function(self, params)
      if quest_prevents_stealing() then
         Gui.mes("magic.steal.in_quest")
         return false
      end

      local source = params.source
      if source:is_player() and not Effect.do_stamina_check(source, self.cost) then
         Gui.mes("magic.common.too_exhausted")
         return true
      end

      Input.query_inventory(source, "elona.inv_steal", {target=params.target, ground_x=params.x, ground_y=params.y})

      return true
   end
}

data:add {
   _id = "riding",
   _type = "base.skill",
   elona_id = 301,

   type = "skill_action",
   effect_id = "elona.riding",
   related_skill = "elona.stat_will",
   ability_type = 0,
   target_type = "nearby",
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
   cost = 20,

   cast = function(self, params)
      Gui.mes("TODO")
      return true
   end
}
