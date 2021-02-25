local Calc = require("mod.elona.api.Calc")
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
local Map = require("api.Map")
local Feat = require("api.Feat")
local Mef = require("api.Mef")
local Charagen = require("mod.tools.api.Charagen")
local ChooseNpcMenu = require("api.gui.menu.ChooseNpcMenu")
local Skill = require("mod.elona_sys.api.Skill")
local I18N = require("api.I18N")
local Wish = require("mod.elona.api.Wish")
local Quest = require("mod.elona.api.Quest")

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
      local map = params.source:current_map()

      if not source:is_player() or target:is_in_player_party() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local prevents_domination = map:calc("prevents_domination")
      if prevents_domination then
         if source:is_in_fov() then
            Gui.mes("magic.domination.does_not_work_in_area")
         end
         return true
      end

      -- TODO item: monster heart

      local success = Rand.rnd(params.power / 15 + 5) < target:calc("level")

      if target:calc("quality") >= Enum.Quality.Good then
         Gui.mes("magic.domination.cannot_be_charmed")
      elseif success then
         source:recruit_as_ally(target)
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
   local enc = source:get_enchantment("elona.res_curse")
   if enc then
      resistance = resistance + enc.power / 2
   end

   if Rand.rnd(resistance) > chance then
      return true
   end

   if target:is_in_player_party() then
      if target:has_trait("elona.res_curse") and Rand.one_in(3) then
         Gui.mes("magic.curse.no_effect")
         return true
      end
   end

   local filter = function(item)
      if not Item.is_alive(item) then
         return false
      end
      if item:calc("curse_state") == Enum.CurseState.Blessed and Rand.one_in(10) then
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
   if item.curse_state == Enum.CurseState.Cursed then
      item.curse_state = Enum.CurseState.Doomed
   else
      item.curse_state = Enum.CurseState.Cursed
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
      "target"
   },

   cast = function(self, params)
      local target = params.target
      if not target:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local s = save.elona
      if s.turns_until_cast_return ~= 0 then
         Gui.mes("magic.return.cancel")
         s.turns_until_cast_return = 0
      else
         if Quest.is_non_returnable_quest_active() then
            Gui.mes("misc.return.forbidden")
            if not Input.yes_no() then
               return false
            end
         end

         local map_uid = Effect.query_return_location(target)

         if Effect.is_cursed(params.curse_state) and Rand.one_in(3) then
            Gui.mes("TODO jail") -- TODO
         end

         if map_uid then
            Gui.mes("misc.return.air_becomes_charged")
            -- TODO dungeon boss
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

      local pocket = Inventory.get_or_create("elona.four_dimensional_pocket")
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

   if not source:is_in_player_party() then
      Gui.mes("common.nothing_happens")
      return false, { obvious = false }
   end

   for _=1, passes do
      for _, x, y in map:iter_tiles() do
         if is_cursed then
            forget_cb(x, y, map)
         else
            local dist = Pos.dist(source.x, source.y, x, y)
            if dist < 7 or Rand.rnd(power+1) > Rand.rnd(dist*8+1) or params.curse_state == Enum.CurseState.Blessed then
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
   Gui.update_minimap()
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
   elona_id = 429,

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
         level = Enum.IdentifyState.Full
      end

      local success = Effect.identify_item(item, level)
      if success then
         if item.identify_state ~= Enum.IdentifyState.Full then
            Gui.mes("ui.inv.identify.partially", item)
         else
            Gui.mes("ui.inv.identify.fully", item:build_name())
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

      if params.curse_state == Enum.CurseState.Normal then
         Gui.mes_visible("magic.uncurse.apply", target.x, target.y, target)
      elseif params.curse_state == Enum.CurseState.Blessed then
         Gui.mes_visible("magic.uncurse.blessed", target.x, target.y, target)
      elseif Effect.is_cursed(params.curse_state) then
         Gui.mes_visible("magic.common.cursed", target.x, target.y, target)
         return Magic.cast("elona.effect_curse", params)
      end

      local filter = function(item)
         if not Item.is_alive(item) or item.curse_state == Enum.CurseState.Normal or item.curse_state == Enum.CurseState.Blessed then
            return false
         end

         if params.curse_state ~= Enum.CurseState.Blessed then
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

         if item.curse_state == Enum.CurseState.Cursed then
            chance = Rand.rnd(200) + 1
         elseif item.curse_state == Enum.CurseState.Doomed then
            chance = Rand.rnd(1000) + 1
         end

         if params.curse_state == Enum.CurseState.Blessed then
            chance = chance / 2 + 1
         end

         if chance > 0 and params.power >= chance then
            total_uncursed = total_uncursed + 1
            item.curse_state = Enum.CurseState.Normal
            item:stack()
         else
            total_resisted = total_resisted + 1
         end
      end

      if total_uncursed > 0 then
         if params.curse_state == Enum.CurseState.Blessed then
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

      if not target:is_in_player_party() then
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

data:add {
   _id = "spell_wall_creation",
   _type = "base.skill",
   elona_id = 438,

   type = "spell",
   effect_id = "elona.wall_creation",
   related_skill = "elona.stat_magic",
   cost = 20,
   range = 0,
   difficulty = 250,
   target_type = "location"
}
data:add {
   _id = "wall_creation",
   _type = "elona_sys.magic",
   elona_id = 438,

   type = "skill",
   params = {
      "source"
   },

   cast = function(self, params)
      local x = params.x
      local y = params.y
      local map = params.source:current_map()

      local tile_id = MapTileset.get("elona.mapgen_wall", map)

      if not Map.is_in_bounds(x, y, map) or not Map.can_access(x, y, map) or not tile_id then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      Gui.mes("magic.create.wall")

      if map:tile(x, y)._id ~= tile_id then
         Gui.play_sound("base.offer1" , x, y)
      end

      map:set_tile(x, y, tile_id)
      map:reveal_tile(x, y)
      Gui.update_screen()

      return true
   end
}


data:add {
   _id = "spell_door_creation",
   _type = "base.skill",
   elona_id = 457,

   type = "spell",
   effect_id = "elona.door_creation",
   related_skill = "elona.stat_magic",
   cost = 15,
   range = 0,
   difficulty = 200,
   target_type = "location"
}
data:add {
   _id = "door_creation",
   _type = "elona_sys.magic",
   elona_id = 457,

   type = "skill",
   params = {
      "source"
   },

   cast = function(self, params)
      local x = params.x
      local y = params.y
      local map = params.source:current_map()

      if not Map.is_in_bounds(x, y, map) or map:tile(x, y).kind == Enum.TileRole.Water then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      Gui.play_sound("base.offer1" , x, y)

      if map:tile(x, y).kind == Enum.TileRole.HardWall then
         Gui.mes("magic.create.door.resist")
         return true
      end

      Gui.mes("magic.create.door.apply")

      local difficulty = Rand.rnd(params.power / 10 + 1)
      Feat.create("elona.door", x, y, {difficulty=difficulty,force=true}, map)
      if map:tile(x, y).is_solid then
         local tile_id = MapTileset.get("elona.mapgen_tunnel", map)
         if tile_id then
            map:set_tile(x, y, tile_id)
         end
      end

      return true
   end
}



data:add {
   _id = "spell_wizards_harvest",
   _type = "base.skill",
   elona_id = 464,

   type = "spell",
   effect_id = "elona.wizards_harvest",
   related_skill = "elona.stat_charisma",
   cost = 45,
   range = 0,
   difficulty = 350,
   target_type = "self"
}
data:add {
   _id = "wizards_harvest",
   _type = "elona_sys.magic",
   elona_id = 464,

   type = "skill",
   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source
      local map = params.source:current_map()

      local cb = Anim.load("elona.anim_sparkle", source.x, source.y)
      Gui.start_draw_callback(cb)

      local times = math.clamp(4 + Rand.rnd(params.power / 50 + 1), 1, 15)

      for i = 1, times do
         Gui.play_sound("base.pray1", source.x, source.y)
         local level = Calc.calc_object_level(params.power / 10, map)
         local quality = Calc.calc_object_quality("good")

         local id = "elona.gold_piece"
         local amount = 400 + Rand.rnd(params.power)

         if Rand.one_in(30) then
            id = "elona.platinum_coin"
            amount = 1
         end
         if Rand.one_in(80) then
            id = "elona.small_medal"
            amount = 1
         end
         if Rand.one_in(2000) then
            id = "elona.rod_of_wishing"
            amount = 1
         end
         local item = Item.create(id, source.x, source.y, {level=level, quality=quality, amount=amount, no_stack=true}, map)
         if item then
            Gui.mes("magic.wizards_harvest", item)
         end
         Gui.wait(100)
         Gui.update_screen()
      end

      return true
   end
}


local function do_restore(chara, attrs, curse_state)
   local quality = chara:calc("quality")

   for _, skill_id in ipairs(attrs) do
      local adj = chara:stat_adjustment(skill_id)
      if Effect.is_cursed(curse_state) then
         if quality <= Enum.Quality.Normal then
            adj = adj - Rand.rnd(chara:base_skill_level(skill_id)) / 5 + Rand.rnd(5)
         end
      else
         adj = math.max(adj, 0)
         if curse_state == Enum.CurseState.Blessed then
            adj = chara:base_skill_level(skill_id) / 10 + 5
         end
      end

      chara:set_stat_adjustment(skill_id, adj)
   end

   chara:refresh()
end


data:add {
   _id = "spell_restore_body",
   _type = "base.skill",
   elona_id = 439,

   type = "spell",
   effect_id = "elona.restore_body",
   related_skill = "elona.stat_will",
   cost = 18,
   range = 0,
   difficulty = 250,
   target_type = "self_or_nearby"
}
data:add {
   _id = "restore_body",
   _type = "elona_sys.magic",
   elona_id = 439,

   type = "skill",
   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      local target = params.target
      local map = params.target:current_map()

      if Effect.is_cursed(params.curse_state) then
         Gui.play_sound("base.curse3")
         Gui.mes_visible("magic.restore.body.cursed", target)
      else
         Gui.mes_visible("magic.restore.body.apply", target)
         local cb = Anim.load("elona.anim_sparkle", target.x, target.y)
         Gui.start_draw_callback(cb)
      end
      if params.curse_state == Enum.CurseState.Blessed then
         Gui.mes_visible("magic.restore.body.blessed", target)
         local cb = Anim.load("elona.anim_sparkle", target.x, target.y)
         Gui.start_draw_callback(cb)
      end

      local attrs = {
         "elona.stat_strength",
         "elona.stat_constitution",
         "elona.stat_dexterity",
         "elona.stat_charisma",
         "elona.stat_speed",
      }
      do_restore(target, attrs, params.curse_state)

      return true
   end
}


data:add {
   _id = "spell_restore_spirit",
   _type = "base.skill",
   elona_id = 440,

   type = "spell",
   effect_id = "elona.restore_spirit",
   related_skill = "elona.stat_will",
   cost = 18,
   range = 0,
   difficulty = 250,
   target_type = "self_or_nearby"
}
data:add {
   _id = "restore_spirit",
   _type = "elona_sys.magic",
   elona_id = 440,

   type = "skill",
   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      local target = params.target
      local map = params.target:current_map()

      if Effect.is_cursed(params.curse_state) then
         Gui.play_sound("base.curse3")
         Gui.mes_visible("magic.restore.mind.cursed", target)
      else
         Gui.mes_visible("magic.restore.mind.apply", target)
         local cb = Anim.load("elona.anim_sparkle", target.x, target.y)
         Gui.start_draw_callback(cb)
      end
      if params.curse_state == Enum.CurseState.Blessed then
         Gui.mes_visible("magic.restore.mind.blessed", target)
         local cb = Anim.load("elona.anim_sparkle", target.x, target.y)
         Gui.start_draw_callback(cb)
      end

      local attrs = {
         "elona.stat_learning",
         "elona.stat_perception",
         "elona.stat_magic",
         "elona.stat_will",
         "elona.stat_luck",
      }
      do_restore(target, attrs, params.curse_state)

      return true
   end
}


data:add {
   _id = "spell_wish",
   _type = "base.skill",
   elona_id = 441,

   type = "spell",
   effect_id = "elona.wish",
   related_skill = "elona.stat_magic",
   cost = 580,
   range = 0,
   difficulty = 5250,
   target_type = "self"
}
data:add {
   _id = "wish",
   _type = "elona_sys.magic",
   elona_id = 441,

   type = "skill",
   params = {
      "source",
   },

   cast = function(self, params)
      local source = params.source

      Wish.query_wish()

      return true
   end
}


data:add {
   _id = "spell_resurrection",
   _type = "base.skill",
   elona_id = 461,

   type = "spell",
   effect_id = "elona.resurrection",
   related_skill = "elona.stat_will",
   cost = 60,
   range = 0,
   difficulty = 1650,
   target_type = "self",

   -- TODO spell description
   calc_mp_cost = function(skill_entry, chara) return skill_entry.cost end
}
data:add {
   _id = "resurrection",
   _type = "elona_sys.magic",
   elona_id = 461,

   type = "skill",
   params = {
      "source",
   },

   dice = function(self, params)
      local level = params.source:skill_level("elona.spell_resurrection")
      return {
         x = 0,
         y = 1,
         bonus = math.clamp((level*5*params.power)/20 + 40, 40, 100)
      }
   end,

   cast = function(self, params)
      local source = params.source
      local map = params.source:current_map()

      if Map.is_world_map(map) then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      if Effect.is_cursed(params.curse_state) then
         Gui.mes("magic.resurrection.cursed")
         for _ = 1, 4 + Rand.rnd(4) do
            local level = Calc.calc_object_level(source:calc("level"))
            local quality = Calc.calc_object_quality("good")
            Charagen.create(nil, nil, { level = level, quality = quality }, map)
         end
         return true, { obvious = false }
      end

      local filter = function(chara)
         return chara.state == "PetDead" or chara.state == "CitizenDead"
      end

      local ally, canceled = ChooseNpcMenu:new(filter):query()

      if not ally or canceled then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      ally:revive()

      local success = Map.try_place_chara(ally, source.x, source.y, map)
      if not success then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      Gui.mes_c("magic.resurrection.apply", "Yellow", ally)
      Gui.mes(I18N.quote_speech("magic.resurrection.dialog"))

      local cb = Anim.miracle({{ x = ally.x, y = ally.y }})
      Gui.start_draw_callback(cb)
      Gui.play_sound("base.pray2")

      ally:set_emotion_icon("elona.heart", 3)

      if source:is_player() then
         Skill.modify_impression(ally, 15)
         if not ally:is_in_player_party() then
            Effect.modify_karma(source, 2)
         end
      end

      return true
   end
}


data:add {
   _id = "spell_meteor",
   _type = "base.skill",
   elona_id = 465,

   type = "spell",
   effect_id = "elona.meteor",
   related_skill = "elona.stat_magic",
   cost = 220,
   range = 0,
   difficulty = 1450,
   target_type = "self"
}
data:add {
   _id = "meteor",
   _type = "elona_sys.magic",
   elona_id = 465,

   type = "skill",
   params = {
      "source",
   },

   cast = function(self, params)
      local source = params.source
      local map = params.source:current_map()

      Gui.mes_c("magic.meteor", "Blue")

      local cb = Anim.meteor()
      Gui.start_draw_callback(cb)

      for _, x, y in map:iter_tiles() do
         if Rand.one_in(3) then
            local tile = Rand.choice {
               "elona.cracked_dirt_1",
               "elona.cracked_dirt_2",
            }
            map:set_tile(x, y, tile)
         end
         if Rand.one_in(40) then
            Mef.create("elona.fire", x, y, {duration=Rand.rnd(4)+3, power=50}, map)
         end

         -- NOTE: also damages caster
         local chara = Chara.at(x, y, map)
         if chara then
            local damage = source:skill_level("elona.stat_magic") * params.power / 10
            chara:damage_hp(damage, source, { element = "elona.fire", element_power = 1000 })
         end
      end

      return true
   end
}
