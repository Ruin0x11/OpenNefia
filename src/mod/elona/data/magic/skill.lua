local Item = require("api.Item")
local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Input = require("api.Input")
local Quest = require("mod.elona_sys.api.Quest")
local elona_Item = require("mod.elona.api.Item")
local Skill = require("mod.elona_sys.api.Skill")
local Hunger = require("mod.elona.api.Hunger")
local Enum = require("api.Enum")
local Pos = require("api.Pos")

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

   Hunger.make_dish(item, food_quality)

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

-- >>>>>>>> shade2/module.hsp:583 #define global cell_find(%%1) f=false:repeat 3:y=cY ...
local function find_cell_with_role(cx, cy, tile_role, map)
   for i = -1, 1 do
      local x = cx + i
      local y = cy
      if map:tile(x, y).kind == tile_role then
         return x, y
      end
   end

   for j = -1, 1 do
      local x = cx
      local y = cy + j
      if map:tile(x, y).kind == tile_role then
         return x, y
      end
   end

   return nil, nil
end
-- <<<<<<<< shade2/module.hsp:590 	loop} ..

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
      "item"
   },
   cost = 5,

   cast = function(self, params)
      -- >>>>>>>> shade2/proc.hsp:2287 	case rsFishing ...
      local source = params.source
      local map = source:current_map()
      local item = params.item

      if source:skill_level("elona.fishing") == 0 then
         Gui.mes("magic.fish.do_not_know")
         return false
      end
      if source:is_inventory_full() then
         Gui.mes("ui.inv.common.inventory_is_full")
         return false
      end
      if not config.base.development_mode and item.params.bait_amount <= 0 then
         Gui.mes("magic.fish.need_bait")
         return false
      end

      local x, y = find_cell_with_role(source.x, source.y, Enum.TileRole.Water, map)

      if x == nil then
         Gui.mes("magic.fish.not_good_place")
         return false
      end

      if map:tile(source.x, source.y).kind == Enum.TileRole.Water then
         Gui.mes("magic.fish.cannot_during_swim")
         return false
      end

      source.direction = Pos.pack_direction(Pos.direction_in(source.x, source.y, x, y))

      if source:is_player() and not Effect.do_stamina_check(source, self.cost) then
         Gui.mes("magic.common.too_exhausted")
         return true
      end

      Gui.add_effect_map("base.effect_map_ripple", x, y, 3)

      item = item:separate()
      item.params.bait_amount = item.params.bait_amount - 1

      source:start_activity("elona.fishing", {x=x,y=y,fishing_pole=item,no_animation=config.elona.skip_fishing_animation})

      return true
      -- <<<<<<<< shade2/proc.hsp:2309 	swbreak ..
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
