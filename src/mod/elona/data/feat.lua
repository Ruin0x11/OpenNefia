local Gui = require("api.Gui")
local Item = require("api.Item")
local Feat = require("api.Feat")
local Log = require("api.Log")
local Map = require("api.Map")
local MapArea = require("api.MapArea")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local ElonaAction = require("mod.elona.api.ElonaAction")
local SkillCheck = require("mod.elona.api.SkillCheck")
local Chara = require("api.Chara")
local Itemgen = require("mod.tools.api.Itemgen")
local Calc = require("mod.elona.api.Calc")
local Anim = require("mod.elona_sys.api.Anim")

data:add {
   _type = "base.feat",
   _id = "door",

   elona_id = 21,
   image = "elona.feat_door_wooden_closed",
   is_solid = true,
   is_opaque = true,

   params = { opened = "boolean", open_sound = "string", close_sound = "string", opened_tile = "string", closed_tile = "string", difficulty = "number" },
   open_sound = "base.door1",
   close_sound = nil,

   closed_tile = "elona.feat_door_wooden_closed",
   opened_tile = "elona.feat_door_wooden_open",

   on_refresh = function(self)
      -- HACK
      self.opened = not not self.opened

      self:reset("can_open", not self.opened, "set")
      self:reset("can_close", self.opened, "set")
      self:reset("is_solid", not self.opened, "set")
      self:reset("is_opaque", not self.opened, "set")
      if self.opened then
         self:reset("image", self.opened_tile)
      else
         self:reset("image", self.closed_tile)
      end
   end,
   on_bumped_into = function(self, chara)
      self:on_open()
   end,
   on_open = function(self, chara)
      if self.opened then
         return
      end

      self.opened = true
      self.is_solid = false
      self.is_opaque = false

      Gui.mes("Open the door.")
      if self.open_sound then
         Gui.play_sound(self.open_sound, self.x, self.y)
      end

      self:refresh()
   end,
   on_close = function(self, chara)
      if not self.opened then
         return
      end

      self.opened = false
      self.is_solid = true
      self.is_opaque = true

      Gui.mes("Close the door.")
      if self.close_sound then
         Gui.play_sound(self.close_sound, self.x, self.y)
      end

      self:refresh()
   end,

   events = {
      {
         id = "base.on_build_feat",
         name = "Set difficulty.",

         callback = function(self)
            self.difficulty = 5
         end
      },
      {
         id = "elona.on_bash",
         name = "Bash to open door",

         callback = function(self, params)
            local basher = params.chara
            Gui.play_sound("base.bash1")
            local difficulty = self.difficulty * 3 + 30
            -- EVENT: on_calc_door_difficulty

            local str = basher:skill_level("elona.stat_strength")

            if Rand.rnd(difficulty) < str and Rand.one_in(2) then
               Gui.mes("Door is destroyed.")
               if self.difficulty > str then
                  Skill.gain_skill_action("elona.stat_strength", (difficulty - str) * 15)
               end
               self:remove_ownership()
               return true
            else
               Gui.mes("Door is bashed.")
               -- EVENT: on_bash_door

               -- TODO
               if Rand.one_in(4) then
                  Gui.mes("magic1")
               end
               if Rand.one_in(3) then
                  Gui.mes("magic2")
               end
               if Rand.one_in(3) then
                  Gui.mes("hurtself", "Purple")
               end
               if Rand.one_in(3) then
                  if self.difficulty > 0 then
                     self.difficulty = self.difficulty - 1
                     Gui.mes_visible("The door cracks.", basher.x, basher.y)
                  end
               end
            end

            return true
         end
      }
   }
}

local function gen_stair(down)
   local field = (down and "on_descend") or "on_ascend"
   local id = (down and "stairs_down") or "stairs_up"
   local elona_id = (down and 11) or 10
   local image = (down and "elona.feat_stairs_down") or "elona.feat_stairs_up"

   return {
      _type = "base.feat",
      _id = id,

      elona_id = elona_id,
      image = image,
      is_solid = false,
      is_opaque = false,

      params = {
         generator_params = "table",
         area_params = "table",
         map_uid = "number",
      },

      on_refresh = function(self)
         self:mod("can_activate", true)
      end,

      on_activate = function(self, chara)
         if not chara:is_player() then
            return
         end

         local success, map, was_generated = MapArea.load_map_of_entrance(self, true)
         if not success then
            Gui.report_error(map)
            return "player_turn_query"
         end

         local params = nil

         local search
         if self._id == "elona.stairs_down" then
            search = "elona.stairs_up"
         else
            search = "elona.stairs_down"
         end

         -- find where to place the player. If the area of the next
         -- map differs, assume we're leaving into the world map.
         local start_x, start_y
         local inner_area = save.base.area_mapping:area_for_map(self:current_map())
         local outer_area = save.base.area_mapping:area_for_map(map)
         assert(inner_area and outer_area, ("%s %s %s"):format(self:current_map().uid, map.uid, inspect(save.base.area_mapping.maps)))
         if inner_area ~= outer_area then
            assert(map.uid == inner_area.outer_map_uid)
            start_x = outer_area.x
            start_y = outer_area.y
         else
            -- Find where the connecting stair is.
            local stair

            -- If the loaded map indicates a start position, assume
            -- stairs are located there.
            if map.player_start_pos then
               local x, y
               if type(map.player_start_pos) == "table" then
                  x = map.player_start_pos.x
                  y = map.player_start_pos.y
               elseif type(map.player_start_pos) == "function" then
                  x, y = map.player_start_pos(Chara.player(), map, self:current_map(), self)
               else
                  error("invalid map start pos: " .. tostring(map.player_start_pos))
               end

               stair = Feat.at(x, y, map):filter(function(f) return f._id == search end):nth(1)
            end

            if stair == nil then
               -- Otherwise, fall back to searching for stairs in the entire map.
               Log.warn("Start position not provided, falling back to searching entire map for stairs.")
               stair = map:iter_feats():filter(function(f) return f._id == search end):nth(1)
            end

            if stair == nil then
               Log.warn("No connecting stair found in other map.")
               start_x = math.floor(map:width() / 2)
               start_y = math.floor(map:height() / 2)
            else
               start_x = stair.x
               start_y = stair.y
               stair.map_uid = self:current_map().uid
            end
         end

         params = {
            start_x = start_x,
            start_y = start_y,
            maybe_regenerate = true,
            feat = self
         }

         Map.travel_to(map, params)

         return "player_turn_query"
      end,

      [field] = function(self, chara)
         self:on_activate(chara)
      end
   }
end

data:add(gen_stair(true))
data:add(gen_stair(false))

data:add {
   _type = "base.feat",
   _id = "map_entrance",

   elona_id = nil,
   image = "elona.feat_area_city",
   is_solid = false,
   is_opaque = false,

   params = {
      generator_params = "table",
      map_uid = "number",
   },

   on_refresh = function(self)
      self:mod("can_activate", true)
   end,

   on_activate = function(self, chara)
      assert(self:current_map())
      if not chara:is_player() then
         return
      end

      local success, map = MapArea.load_map_of_entrance(self, false)
      if not success then
         Gui.report_error(map)
         return "player_turn_query"
      end

      Map.travel_to(map, {maybe_regenerate = true})

      return "player_turn_query"
   end,

   on_descend = function(self, chara)
      self:on_activate(chara)
   end
}

data:add {
   _type = "base.feat",
   _id = "pot",

   elona_id = 30,
   image = "elona.feat_pot",
   is_solid = false,
   is_opaque = false,

   params = { },

   events = {
      {
         id = "elona.on_bash",
         name = "Bash to shatter pot",

         callback = function(self, params)
            local map = self:current_map()
            local basher = params.chara

            self.image = nil
            -- TODO: spill fragment
            local level = map:calc("dungeon_level")
            if map.gen_id == "elona.shelter" then level = 0 end

            Itemgen.create(self.x, self.y, Calc.filter(level, 1), map)

            map:memorize_tile(self.x, self.y)
            Gui.update_screen()

            if Map.is_in_fov(basher.x, basher.y) then
               Gui.play_sound("base.bash1")
               Gui.mes("action.bash.shatters_pot", basher)
               Gui.play_sound("base.crush1")
               local anim = Anim.breaking(self.x, self.y)
               Gui.start_draw_callback(anim)
            end
            self:remove_ownership()
            return true
         end
      },
      {
         id = "elona_sys.on_bump_into",
         name = "Bump into to shatter pot",

         callback = function(self, params)
            print("on_bump")
            return ElonaAction.bash(params.chara, self.x, self.y)
         end
      }
   }
}


data:add {
   _type = "base.feat",
   _id = "hidden_path",

   elona_id = 22,
   image = "elona.feat_hidden",
   is_solid = false,
   is_opaque = false,

   on_search = function(self, chara)
      if SkillCheck.try_to_reveal(chara) then
         Gui.mes("reveal hidden path")
         Map.set_tile(self.x, self.y, "elona.hardwood_floor_1", chara:current_map())
         self:remove_ownership()
      end
   end,

   params = {},
   events = {}
}

data:add {
   _type = "base.feat",
   _id = "quest_board",

   elona_id = 23,
   image = "elona.feat_quest_board",
   is_solid = true,
   is_opaque = false,

   on_bumped_into = function(self, chara)
      Gui.play_sound("base.chat")
      Gui.mes("Quest board.")
   end,

   params = {},
   events = {}
}

data:add {
   _type = "base.feat",
   _id = "voting_box",

   elona_id = 31,
   image = "elona.feat_voting_box",
   is_solid = true,
   is_opaque = false,

   on_bumped_into = function(self, chara)
      Gui.play_sound("base.chat")
      Gui.mes("Voting box.")
   end,

   params = {},
   events = {}
}

data:add {
   _type = "base.feat",
   _id = "small_medal",

   elona_id = 32,
   image = "elona.feat_hidden",
   is_solid = false,
   is_opaque = false,

   on_search = function(self, chara)
      Gui.mes("reveal medal")
      self:remove_ownership()
   end,

   params = {},
   events = {}
}

data:add {
   _type = "base.feat",
   _id = "politics_board",

   elona_id = 33,
   image = "elona.feat_politics_board",
   is_solid = true,
   is_opaque = false,

   on_bumped_into = function(self, chara)
      Gui.play_sound("base.chat")
      Gui.mes("Politics board.")
   end,

   params = {},
   events = {}
}
