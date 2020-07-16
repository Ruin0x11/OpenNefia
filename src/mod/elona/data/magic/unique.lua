local Pos = require("api.Pos")
local Enum = require("api.Enum")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Effect = require("mod.elona.api.Effect")
local Rand = require("api.Rand")
local Item = require("api.Item")
local Anim = require("mod.elona_sys.api.Anim")
local Inventory = require("api.Inventory")
local Input = require("api.Input")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")
local Magic = require("mod.elona_sys.api.Magic")

local RANGE_BOLT = 6
local RANGE_BALL = 2
local RANGE_BREATH = 5

data:add {
   _id = "spell_gravity",
   _type = "base.skill",
   elona_id = 466,

   type = "spell",
   effect_id = "elona.gravity",
   related_skill = "elona.stat_magic",
   cost = 24,
   range = RANGE_BALL,
   difficulty = 750,
   target_type = "self_or_nearby"
}
data:add {
   _id = "gravity",
   _type = "elona_sys.magic",
   elona_id = 466,

   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source

      local filter = function(chara)
         return chara ~= source
            and not chara:calc("is_immune_to_mines")
            and Pos.dist(source.x, source.y, chara.x, chara.y) <= params.range * 2
      end

      for _, chara in Chara.iter():filter(filter) do
         Gui.mes_visible("magic.gravity", chara.x, chara.y)
         chara:apply_effect("elona.gravity", 100 + Rand.rnd(100))
      end

      return true
   end
}

data:add {
   _id = "spell_dominate",
   _type = "base.skill",
   elona_id = 435,

   type = "spell",
   effect_id = "elona.dominate",
   related_skill = "elona.stat_charisma",
   cost = 125,
   range = RANGE_BOLT,
   difficulty = 2000,
   target_type = "enemy"
}
data:add {
   _id = "dominate",
   _type = "elona_sys.magic",
   elona_id = 435,

   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target

      if not source:is_player() or target:is_allied() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      -- TODO dominate restriction
      -- TODO item: monster heart

      local success = Rand.rnd(params.power / 15 + 5) < target:calc("level")

      if target:calc("quality") >= Enum.Quality.Great then
         Gui.mes("magic.domination.cannot_be_charmed")
      elseif success then
         target:recruit_as_ally()
      else
         Gui.mes("magic.common.resists")
      end

      return true
   end
}

local function do_curse(self, params)
   local source = params.source
   local target = params.target

   local chance = params.power / 2
   if Effect.is_cursed(params.curse_state) then
      chance = chance * 100
   end
   local resistance = 75 + target:skill_level("elona.stat_luck")
   -- TODO enchantment: resist curse
   if Rand.rnd(resistance) > chance then
      return true
   end

   if target:is_allied() then
      if target:has_trait("elona.res_curse") and Rand.one_in(3) then
         Gui.mes("magic.curse.no_effect")
         return true
      end
   end

   local filter = function(item)
      if not Item.is_alive(item) then
         return false
      end
      if item:calc("curse_state") == "blessed" and Rand.one_in(10) then
         return false
      end
      return true
   end

   local considering = target:iter_equipment():filter(filter):to_list()

   if #considering == 0 then
      local items = target:iter_inventory():to_list()
      for _ = 1, 200 do
         local item = Rand.choice(items)
         if filter(item) then
            considering[#considering+1] = item
            break
         end
      end
   end

   if #considering == 0 then
      Gui.mes("common.nothing_happens")
      return true, { obvious = false }
   end

   local item = Rand.choice(considering)

   Gui.mes_visible("magic.curse.apply", target.x, target.y, target, item)
   if item.curse_state == "cursed" then
      item.curse_state = "doomed"
   else
      item.curse_state = "cursed"
   end
   target:refresh()
   Gui.play_sound("base.curse3")
   local cb = Anim.load("elona.anim_curse", target.x, target.y)
   Gui.start_draw_callback(cb)
   item:stack()

   return true
end

data:add {
   _id = "action_curse",
   _type = "base.skill",
   elona_id = 645,

   type = "action",
   effect_id = "elona.curse",
   related_skill = "elona.stat_magic",
   cost = 10,
   range = 4,
   difficulty = 100,
   target_type = "enemy"
}
data:add {
   _id = "curse",
   _type = "elona_sys.magic",
   elona_id = 645,

   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      Gui.mes_visible("magic.curse.spell", params.target.x, params.target.y, params.source, params.target)

      return do_curse(self, params)
   end
}

data:add {
   _id = "effect_curse",
   _type = "elona_sys.magic",
   elona_id = 1114,

   params = {
      "source",
      "target"
   },

   cast = do_curse
}

data:add {
   _id = "spell_return",
   _type = "base.skill",
   elona_id = 428,

   type = "spell",
   effect_id = "elona.return",
   related_skill = "elona.stat_perception",
   cost = 28,
   range = 0,
   difficulty = 550,
   target_type = "self"
}
data:add {
   _id = "return",
   _type = "elona_sys.magic",
   elona_id = 428,

   type = "skill",
   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source
      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local s = save.elona
      if s.turns_until_cast_return ~= 0 then
         Gui.mes("magic.return.cancel")
         s.turns_until_cast_return = 0
      else
         local map_uid = Effect.query_return_location(source)

         if Effect.is_cursed(params.curse_state) and Rand.one_in(3) then
            Gui.mes("jail") -- TODO
         end

         if map_uid then
            s.return_destination_map_uid = map_uid
            s.turns_until_cast_return = 15 + Rand.rnd(15)
         end
      end

      return true
   end
}

data:add {
   _id = "spell_four_dimensional_pocket",
   _type = "base.skill",
   elona_id = 463,

   type = "spell",
   effect_id = "elona.four_dimensional_pocket",
   related_skill = "elona.stat_perception",
   cost = 60,
   range = 0,
   difficulty = 750,
   target_type = "self"
}
data:add {
   _id = "four_dimensional_pocket",
   _type = "elona_sys.magic",
   elona_id = 463,

   type = "skill",
   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source

      Gui.play_sound("base.teleport1")
      Gui.mes("magic.four_dimensional_pocket")

      local s = save.elona
      if s.four_dimensional_pocket == nil then
         s.four_dimensional_pocket = Inventory:new()
      end

      local pocket = s.four_dimensional_pocket
      pocket:set_max_size(math.clamp(math.floor(params.power / 10 + 10), 10, 300))
      pocket.max_weight = params.power * 100

      Input.query_inventory(source, "elona.inv_get_pocket", { container = pocket }, "elona.four_dimensional_pocket")

      return false
   end
}

local function do_sense(self, params, passes, reveal_cb, forget_cb, message)
   local curse_state = params.curse_state
   local is_cursed = Effect.is_cursed(curse_state)
   local source = params.source
   local power = params.power
   local map = params.source:current_map()

   if not source:is_allied() then
      Gui.mes("common.nothing_happens")
      return false, { obvious = false }
   end

   for _=1, passes do
      for _, x, y in map:iter_tiles() do
         if is_cursed then
            forget_cb(x, y, map)
         else
            local dist = Pos.dist(source.x, source.y, x, y)
            if dist < 7 or Rand.rnd(power+1) > Rand.rnd(dist*8+1) or params.curse_state == "blessed" then
               reveal_cb(x, y, map)
            end
         end
      end
   end

   if is_cursed then
      Gui.mes("magic.sense.cursed")
   else
      Gui.mes(message, source)
   end

   local cb = Anim.load("elona.anim_sparkle", source.x, source.y)
   Gui.start_draw_callback(cb)
   -- TODO refresh minimap
end

data:add {
   _id = "spell_magic_map",
   _type = "base.skill",
   elona_id = 429,

   type = "spell",
   effect_id = "elona.magic_map",
   related_skill = "elona.stat_perception",
   cost = 30,
   range = 0,
   difficulty = 450,
   target_type = "self"
}
data:add {
   _id = "magic_map",
   _type = "elona_sys.magic",
   elona_id = 463,

   type = "skill",
   params = {
      "source"
   },

   cast = function(self, params)
      local map = params.source:current_map()
      local default_tile = MapTileset.get_default_tile("elona.mapgen_tunnel", map)

      local reveal = function(x, y, map)
         map:memorize_tile(x, y, "tile")
      end
      local forget = function(x, y, map)
         map:reveal_tile(x, y, default_tile)
      end

      return do_sense(self, params, 2, reveal, forget, "magic.sense.magic_mapping")
   end
}

data:add {
   _id = "spell_sense_object",
   _type = "base.skill",
   elona_id = 430,

   type = "spell",
   effect_id = "elona.sense_object",
   related_skill = "elona.stat_perception",
   cost = 22,
   range = 0,
   difficulty = 250,
   target_type = "self"
}
data:add {
   _id = "sense_object",
   _type = "elona_sys.magic",
   elona_id = 430,

   type = "skill",
   params = {
      "source"
   },

   cast = function(self, params)
      local reveal = function(x, y, map)
         map:reveal_objects(x, y)
      end
      local forget = function(x, y, map)
         map:forget_objects(x, y)
      end

      return do_sense(self, params, 1, reveal, forget, "magic.sense.sense_object")
   end
}

data:add {
   _id = "spell_identify",
   _type = "base.skill",
   elona_id = 411,

   type = "spell",
   effect_id = "elona.identify",
   related_skill = "elona.stat_perception",
   cost = 28,
   range = 0,
   difficulty = 800,
   target_type = "self"
}
data:add {
   _id = "identify",
   _type = "elona_sys.magic",
   elona_id = 411,

   type = "skill",
   params = {
      "source"
   },

   dice = function(self, params)
      local level = params.source:skill_level("elona.spell_identify")
      return {
         x = 0,
         y = 1,
         bonus = level * params.power * 10 / 100
      }
   end,

   cast = function(self, params)
      local source = params.source
      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local result, canceled = Input.query_item(source, "elona.inv_identify")

      if canceled then
         return true
      end

      local item = result.result

      local level = "unidentified"
      if params.power >= item:calc("identify_difficulty") then
         level = "completely"
      end

      local success = Effect.identify_item(item, level)
      if success then
         if item.identify_state ~= "completely" then
            Gui.mes("ui.inv.identify.partially", item)
         else
            Gui.mes("ui.inv.identify.fully", item)
         end
      else
         Gui.mes("ui.inv.identify.need_more_power")
      end

      item:stack()

      return true
   end
}

data:add {
   _id = "spell_uncurse",
   _type = "base.skill",
   elona_id = 412,

   type = "spell",
   effect_id = "elona.uncurse",
   related_skill = "elona.stat_will",
   cost = 35,
   range = 0,
   difficulty = 700,
   target_type = "self_or_nearby"
}
data:add {
   _id = "uncurse",
   _type = "elona_sys.magic",
   elona_id = 412,

   type = "skill",
   params = {
      "source"
   },

   dice = function(self, params)
      local level = params.source:skill_level("elona.spell_uncurse")
      return {
         x = 0,
         y = 1,
         bonus = level * params.power * 5 / 100
      }
   end,

   cast = function(self, params)
      local target = params.target

      if params.curse_state == "none" then
         Gui.mes_visible("magic.uncurse.apply", target.x, target.y, target)
      elseif params.curse_state == "blessed" then
         Gui.mes_visible("magic.uncurse.blessed", target.x, target.y, target)
      elseif Effect.is_cursed(params.curse_state) then
         Gui.mes_visible("magic.common.cursed", target.x, target.y, target)
         return Magic.cast("elona.effect_curse", params)
      end

      local filter = function(item)
         if not Item.is_alive(item) or item.curse_state == "none" or item.curse_state == "blessed" then
            return false
         end

         if params.curse_state ~= "blessed" then
            if not item:is_equipped() then
               return false
            end
         end

         return true
      end

      local total_uncursed = 0
      local total_resisted = 0

      for _, item in target:iter_items():filter(filter) do
         local chance = 0

         if item.curse_state == "cursed" then
            chance = Rand.rnd(200) + 1
         elseif item.curse_state == "doomed" then
            chance = Rand.rnd(1000) + 1
         end

         if params.curse_state == "blessed" then
            chance = chance / 2 + 1
         end

         if chance > 0 and params.power >= chance then
            total_uncursed = total_uncursed + 1
            item.curse_state = "none"
            item:stack()
         else
            total_resisted = total_resisted + 1
         end
      end

      if total_uncursed > 0 then
         if params.curse_state == "blessed" then
            Gui.mes_visible("magic.uncurse.item", target.x, target.y, target)
         else
            Gui.mes_visible("magic.uncurse.equipment", target.x, target.y, target)
         end
      end
      if total_resisted > 0 then
         Gui.mes_visible("magic.uncurse.resist", target.x, target.y)
      end

      local obvious = true

      if total_uncursed == 0 and total_resisted == 0 then
         Gui.mes("common.nothing_happens")
         obvious = false
      else
         local cb = Anim.load("elona.anim_sparkle", target.x, target.y)
         Gui.start_draw_callback(cb)
      end

      target:refresh()

      return true, { obvious = obvious }
   end
}

data:add {
   _id = "spell_oracle",
   _type = "base.skill",
   elona_id = 413,

   type = "spell",
   effect_id = "elona.oracle",
   related_skill = "elona.stat_magic",
   cost = 150,
   range = 0,
   difficulty = 1500,
   target_type = "self_or_nearby"
}
data:add {
   _id = "oracle",
   _type = "elona_sys.magic",
   elona_id = 413,

   type = "skill",
   params = {
      "source"
   },

   cast = function(self, params)
      local target = params.target

      if not target:is_allied() then
         Gui.mes("common.nothing_happens")
         return true
      end

      Gui.mes("TODO")

      if Effect.is_cursed(params.curse_state) then
         Gui.mes("magic.oracle.cursed")
         return true
      end

      return true
   end
}
