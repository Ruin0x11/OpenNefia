local Enum = require("api.Enum")
local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Item = require("api.Item")
local Log = require("api.Log")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local ElonaAction = require("mod.elona.api.ElonaAction")
local SkillCheck = require("mod.elona.api.SkillCheck")
local Chara = require("api.Chara")
local Itemgen = require("mod.elona.api.Itemgen")
local Calc = require("mod.elona.api.Calc")
local Anim = require("mod.elona_sys.api.Anim")
local Pos = require("api.Pos")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")
local QuestBoardMenu = require("api.gui.menu.QuestBoardMenu")
local Quest = require("mod.elona_sys.api.Quest")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Magic = require("mod.elona_sys.api.Magic")
local I18N = require("api.I18N")
local ExHelp = require("mod.elona.api.ExHelp")
local Area = require("api.Area")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local Filters = require("mod.elona.api.Filters")
local NefiaCompletionDrawable = require("mod.elona.api.gui.NefiaCompletionDrawable")
local Nefia = require("mod.elona.api.Nefia")

local function get_map_display_name(area, description)
   if area.metadata.is_hidden then
      return ""
   end

   local _id = area._archetype or "<no archetype>"

   local desc = I18N.get_optional("map.unique." .. _id .. ".desc")
   local name = area.name or I18N.get_optional("map.unique." .. _id .. ".name")
   if name == nil and desc then
      name = desc
   end

   if name == nil then
      name = area.name
   end

   if not description then
      return name
   end

   local text
   if Nefia.get_type(area) then
      text = I18N.get("map.you_see_an_entrance", name, Nefia.get_level(area))
   elseif desc then
      text = desc
   else
      text = I18N.get("map.you_see", name)
   end

   return text
end

data:add {
   _type = "base.feat",
   _id = "door",
   elona_id = 21,
   image = "elona.feat_door_wooden_closed",
   is_solid = true,
   is_opaque = true,
   params = {
      opened = "boolean",
      open_sound = "string",
      close_sound = "string",
      opened_tile = "string",
      closed_tile = "string",
      difficulty = "number"
   },
   open_sound = "base.door1",
   close_sound = nil,
   closed_tile = "elona.feat_door_wooden_closed",
   opened_tile = "elona.feat_door_wooden_open",
   on_refresh = function(self)
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
   on_bumped_into = function(self, params) self.proto.on_open(self, params) end,

   on_open = function(self, params)
      if self.opened then return end

      self.opened = true
      self.is_solid = false
      self.is_opaque = false

      Gui.mes("action.open.door.succeed", params.chara)
      if self.open_sound then
         Gui.play_sound(self.open_sound, self.x, self.y)
      end

      self:refresh()
   end,
   on_close = function(self, params)
      if not self.opened then return end

      self.opened = false
      self.is_solid = true
      self.is_opaque = true

      Gui.mes("action.close.execute", params.chara)
      if self.close_sound then
         Gui.play_sound(self.close_sound, self.x, self.y)
      end

      self:refresh()
   end,
   on_bash = function(self, params)
      -- >>>>>>>> elona122/shade2/action.hsp:443 		if feat(1)=objDoorClosed{ ..
      if self.opened then
         return nil
      end

      local basher = params.chara
      Gui.play_sound("base.bash1")

      local difficulty = self.difficulty * 3 + 30
      local is_jail = self:current_map()._archetype == "elona.jail"

      if is_jail then
         difficulty = difficulty * 20
      end

      local str = basher:skill_level("elona.stat_strength")

      if Rand.rnd(difficulty) < str and Rand.one_in(2) then
         Gui.mes("action.bash.door.destroyed")
         if self.difficulty > str then
            Skill.gain_skill_exp("elona.stat_strength", (self.difficulty - str) * 15)
         end
         self:remove_ownership()
         return "turn_end"
      else
         Gui.mes("action.bash.door.execute")
         if is_jail then
            Gui.mes("action.bash.door.jail")
         end

         if Rand.one_in(4) then
            basher:apply_effect("elona.confusion", 200)
         end
         if Rand.one_in(3) then
            basher:apply_effect("elona.paralysis", 200)
         end
         if Rand.one_in(3) then
            if basher:calc("quality") < Enum.Quality.Great
               and not Effect.has_sustain_enchantment(basher, "elona.stat_strength")
            then
               basher:add_stat_adjustment("elona.stat_strength", -1)
               basher:refresh()
               Gui.mes_c("action.bash.door.hurt", "Purple", basher)
            end
         end
         if Rand.one_in(3) then
            if self.difficulty > 0 then
               self.difficulty = self.difficulty - 1
               Gui.mes_visible("action.bash.door.cracked", basher)
            end
         end
      end


      return "turn_end"
      -- <<<<<<<< elona122/shade2/action.hsp:464 		} ..
   end,
   events = {
      {
         id = "base.on_build_feat",
         name = "Set difficulty.",
         callback = function(self) self.difficulty = 5 end
      }
   }
}


local function entrance_in_parent_map(map, area, parent_area, chara, prev)
   local x, y, floor = parent_area:child_area_position(area)
   if x == nil or floor ~= parent_area:floor_of_map(map.uid) then
      return nil
   end

   local index = 0
   for i, c in Chara.iter_allies(prev) do
      if c.uid == chara.uid then
         index = i
         break
      end
   end

   return { x = x + Rand.rnd(math.floor(index / 5) + 1), y = y + Rand.rnd(math.floor(index / 5) + 1) }
end

local function travel(start_pos_fn, set_prev_map)
   return function(self, params)
      local chara = params.chara
      if not chara:is_player() then return end

      local result = self:emit("elona.before_travel_using_feat", {chara=chara}, { blocked = false, turn_result = nil })
      if result.blocked then
         return result.turn_result or "player_turn_query"
      end

      Gui.play_sound("base.exitmap1")

      local prev_map = self:current_map()
      local prev_area = Area.for_map(prev_map)
      local parent_area = Area.parent(prev_area)
      local start_x, start_y
      local area, map

      if self.params.area_uid then
         area = Area.get(self.params.area_uid)
         if area == nil then
            Log.error("Missing area with UID '%d'", self.params.area_uid)
            return "player_turn_query"
         end

         local ok
         ok, map = area:load_or_generate_floor(self.params.area_floor)
         if not ok then
            local err = map
            if err == "no_archetype" then
               Log.error("Area does not specify an archetype, so there is no way to know what kind of map should be generated. Use InstancedArea:set_archetype(archetype_id) to set one.")
            else
               error(("Missing map with floor number '%d' in area '%d' (%s)"):format(self.params.area_floor, area.uid, err))
            end
            return "player_turn_query"
         end

         local starting_pos
         local map_archetype = map:archetype()

         local function start_pos_or_archetype(map, chara, prev_map, self)
            local pos
            if start_pos_fn then
               pos = start_pos_fn(map, chara, prev_map, self)
               if pos == nil then
                  Log.debug("No stairs found in connecting map, attempting to use map archetype's starting position.")
                  if map_archetype and map_archetype.starting_pos then
                     pos = map_archetype.starting_pos(map, chara, prev_map, self)
                  end
               end
            elseif map_archetype and map_archetype.starting_pos then
               pos = map_archetype.starting_pos(map, chara, prev_map, self)
            end
            return pos
         end

         -- >>>>>>>> shade2/map.hsp:152 		if feat(1)=objDownstairs :msgTemp+=lang("階段を降りた。 ..
         if self.params.area_starting_x and self.params.area_starting_y then
            starting_pos = { x = self.params.area_starting_x, y = self.params.area_starting_y }
         else
            if area.uid ~= prev_area.uid then
               -- If the area we're trying to travel to is the parent of this area, then
               -- put the player directly on the area's entrance.
               if parent_area == area then
                  -- TODO allow configuring ally start positions in Map.travel_to() (mStartWorld)
                  starting_pos = entrance_in_parent_map(map, prev_area, parent_area, chara, prev_map)
                  if starting_pos == nil then
                     -- Assume there will be stairs in the connecting map, and if
                     -- not fall back to the archetype's declared map start
                     -- position.
                     starting_pos = start_pos_or_archetype(map, chara, prev_map, self)
                  end
               else
                  -- We're going into a dungeon. Assume there's stairs there, and
                  -- if not fall back to the archetype.
                  starting_pos = start_pos_or_archetype(map, chara, prev_map, self)

                  if prev_area:has_child_area(area) then
                     -- `prev_area` contains the entrance to this area.
                     local floor = assert(Map.floor_number(prev_map))
                     prev_area:set_child_area_position(area, chara.x, chara.y, floor)
                  end
               end
            else
               starting_pos = start_pos_or_archetype(map, chara, prev_map, self)
            end
         end

         if starting_pos == nil then
            Log.error("Map does not declare a start position. Defaulting to the center of the map.")
            starting_pos = MapEntrance.center(map, chara, prev_map, self)
         end

         if starting_pos.x and starting_pos.y then
            start_x = starting_pos.x
            start_y = starting_pos.y
         end
         -- <<<<<<<< shade2/map.hsp:153 		if feat(1)=objUpstairs	 :msgTemp+=lang("階段を昇った。" ..
      else
         Log.error("This staircase (%s) doesn't have an area UID set.", self)
         return "player_turn_query"
      end

      local travel_params = {
         feat = self,
         start_x = start_x,
         start_y = start_y
      }

      -- If we're entering from the world map, set the previous map so we know
      -- where to go if exiting from the edge.
      if set_prev_map then
         map:set_previous_map_and_location(prev_map, self.x, self.y)
      end

      Map.travel_to(map, travel_params)

      return "player_turn_query"
   end
end

local function gen_stair(down)
   local field = (down and "on_descend") or "on_ascend"
   local id = (down and "stairs_down") or "stairs_up"
   local elona_id = (down and 11) or 10
   local image = (down and "elona.feat_stairs_down") or "elona.feat_stairs_up"
   local start_pos_fn = (down and MapEntrance.stairs_up) or MapEntrance.stairs_down
   local stepped_on_mes = (down and "action.move.feature.stair.down") or "action.move.feature.stair.up"

   return {
      _type = "base.feat",
      _id = id,
      elona_id = elona_id,

      image = image,
      is_solid = false,
      is_opaque = false,

      params = {
         area_uid = nil,
         area_floor = nil,
      },

      on_refresh = function(self)
         self:mod("can_activate", true)
      end,

      on_stepped_on = function(self, params)
         if params.chara:is_player() and self.params.area_uid then
            local area = Area.get(self.params.area_uid)
            if area then
               Gui.mes(stepped_on_mes)
            end
         end
      end,

      on_activate = travel(start_pos_fn),

      -- NOTE: assumes polymorphism between params of elona_sys.on_feat_activate
      -- and elona_sys.on_feat_ascend/elona_sys.on_feat_descend
      [field] = function(self, params) self.proto.on_activate(self, params) end
   }
end

data:add(gen_stair(true))
data:add(gen_stair(false))

data:add
{
   _type = "base.feat",
   _id = "map_entrance",
   elona_id = 15,

   image = "elona.feat_area_city",
   is_solid = false,
   is_opaque = false,

   params = {
      area_uid = nil,
      area_floor = nil,
   },

   on_refresh = function(self)
      self:mod("can_activate", true)
   end,

   on_activate = travel(nil, true),

   on_descend = function(self, params) self.proto.on_activate(self, params) end,

   on_stepped_on = function(self, params)
      if params.chara:is_player() and self.params.area_uid then
         local area = Area.get(self.params.area_uid)
         if area then
            -- >>>>>>>> shade2/action.hsp:758 			if feat(1)=objArea		:txt mapName(feat(2)+feat(3 ...
            if Nefia.get_type(area) then
               ExHelp.maybe_show("elona.random_dungeon")
            end
            -- <<<<<<<< shade2/action.hsp:758 			if feat(1)=objArea		:txt mapName(feat(2)+feat(3 ..
            Gui.mes(get_map_display_name(area, true))
         end
      end
   end,

   events = {
      {
         id = "base.on_feat_make_target_text",
         name = "Target text",

         callback = function(self)
            -- >>>>>>>> shade2/command.hsp:49 		if mType=mTypeWorld{ ...
            local map = self:current_map()
            if not map:has_type("world_map") then
               return nil
            end

            local area = Area.get(self.params.area_uid)
            if area == nil or area._archetype == nil then
               return nil
            end

            return get_map_display_name(area, true)
            -- <<<<<<<< shade2/command.hsp:53 				} ..
         end
      },
      {
         id = "base.on_feat_instantiated",
         name = "Add nefia completion drawable and light",

         callback = function(self)
            if self.params.area_uid ~= nil then
               local area = Area.get(self.params.area_uid)
               if area and Nefia.get_type(area) then
                  local state
                  if area.deepest_floor_visited == area:deepest_floor() then
                     state = "conquered"
                  elseif area.deepest_floor_visited > 0 then
                     state = "in_progress"
                  end
                  self:set_drawable("elona.nefia_completion", NefiaCompletionDrawable:new(state), "above", 200000)
               else
                  self:set_drawable("elona.nefia_completion", nil)
               end

               -- >>>>>>>> shade2/map.hsp:2442 	if (areaType(cnt)=mTypeTown)or(areaType(cnt)=mTyp ...
               if area then
                  local has_light = area.metadata.has_light or area:has_type("town") or area:has_type("guild")

                  if has_light then
                     self.light = {
                        chip = "light_town_light",
                        bright = 140,
                        offset_y = 48 - 48,
                        power = 10,
                        flicker = 20,
                        always_on = false
                     }
                     self:refresh_cell_on_map()
                  end
               end
               -- <<<<<<<< shade2/map.hsp:2442 	if (areaType(cnt)=mTypeTown)or(areaType(cnt)=mTyp ..

               if area.metadata.is_hidden then
                  self.image = nil
               end
            end
         end
      }
   }
}

data:add {
   _type = "base.feat",
   _id = "pot",
   elona_id = 30,

   image = "elona.feat_pot",
   is_solid = true,
   is_opaque = false,

   params = {},

   on_bash = function(self, params)
      local map = self:current_map()
      local basher = params.chara

      self.image = nil

      local level = map:calc("level")
      if map._archetype == "elona.shelter" then level = 0 end

      local filter = {
         level = Calc.calc_object_level(level, map),
         quality = Calc.calc_object_quality(Enum.Quality.Good),
         categories = Rand.choice(Filters.fsetbarrel)
      }
      Itemgen.create(self.x, self.y, filter, map)

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

      return "turn_end"
   end,

   events = {
      {
         id = "elona_sys.on_bump_into",
         name = "Bump into to shatter pot",
         callback = function(self, params)
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

   on_search_from_distance = function(self, params)
      local chara = params.chara

      if math.abs(chara.y - self.y) > 1 or math.abs(chara.x - self.x) > 1 then
         return
      end

      if SkillCheck.try_to_reveal(chara) then
         local map = chara:current_map()
         local tile = MapTileset.get("elona.mapgen_tunnel", map)
         Map.set_tile(self.x, self.y, tile, map)
         self:remove_ownership()
         Gui.mes("action.search.discover.hidden_path")
      end
   end,

   events = {
      {
         id = "elona.on_feat_tile_digged_into",
         name = "Reveal hidden path.",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1069 			if map(refX,refY,6)!0{ ...
            local map = self:current_map()
            local tile = MapTileset.get("elona.mapgen_tunnel", map)
            Map.set_tile(self.x, self.y, tile, map)
            self:remove_ownership()
            -- <<<<<<<< shade2/proc.hsp:1072 				}		 ..
         end
      }
   }
}

local function visit_quest_giver(quest)
   local player = Chara.player()
   local map = player:current_map()
   local client = Chara.find(quest.client_uid, "all", map)
   assert(client)
   Magic.cast("elona.shadow_step", {source=player, target=client})
   if Chara.is_alive(client) then
      Dialog.start(client, "elona.quest_giver:quest_about")
   end

   -- TODO return turn event?
   return nil
end

data:add {
   _type = "base.feat",
   _id = "quest_board",
   elona_id = 23,

   image = "elona.feat_quest_board",
   is_solid = true,
   is_opaque = false,

   on_bumped_into = function(self, params)
      local pred = function(quest)
         return quest.originating_map_uid == self:current_map().uid
            and quest.state == "not_accepted"
      end
      local quests_here = Quest.iter():filter(pred):to_list()
      local quest, canceled = QuestBoardMenu:new(quests_here):query()
      if quest == nil or canceled then
         return
      end

      return visit_quest_giver(quest)
   end,
}

data:add {
   _type = "base.feat",
   _id = "voting_box",
   elona_id = 31,

   image = "elona.feat_voting_box",
   is_solid = true,
   is_opaque = false,

   on_bumped_into = function(self, params)
      Gui.play_sound("base.chat")
      Gui.mes("Voting box.")
   end
}

data:add {
   _type = "base.feat",
   _id = "small_medal",
   elona_id = 32,

   image = "elona.feat_hidden",
   is_solid = false,
   is_opaque = false,

   on_search_from_distance = function(self, params)
      local chara = params.chara
      if chara.x == self.x and chara.y == self.y then
         Gui.play_sound("base.ding2")
         Gui.mes("action.search.small_coin.find")
         Item.create("elona.small_medal", self.x, self.y)
         self:remove_ownership()
      else
         if Pos.dist(chara.x, chara.y, self.x, self.y) > 2 then
            Gui.mes("action.search.small_coin.far")
         else
            Gui.mes("action.search.small_coin.close")
         end
      end
   end,
}

data:add {
   _type = "base.feat",
   _id = "politics_board",
   elona_id = 33,

   image = "elona.feat_politics_board",
   is_solid = true,
   is_opaque = false,

   on_bumped_into = function(self, params)
      Gui.play_sound("base.chat")
      Gui.mes("Politics board.")
   end,
}


-- TODO feat: trap handling (procMove)

data:add {
   _type = "base.feat",
   _id = "mine",
   elona_id = 14,
   elona_sub_id = 7,

   image = "elona.feat_trap",
   is_solid = false,
   is_opaque = false,

   on_stepped_on = function(self, params)
      local chara = params.chara
      Gui.mes_c("action.move.trap.activate.mine", "SkyBlue")
      local cb = Anim.ball({{ chara.x, chara.y }}, nil, nil, chara.x, chara.y, chara:current_map())
      Gui.start_draw_callback(cb)
      self:remove_ownership()
      params.chara:damage_hp(100+Rand.rnd(200), "elona.trap")
   end,
}

-- For dungeon generation.
data:add {
   _type = "base.feat",
   _id = "mapgen_block",

   is_solid = true,
   is_opaque = true
}

data:add {
   _type = "base.feat",
   _id = "plant",
   elona_id = 29,

   image = "elona.feat_plant_0",
   is_solid = false,
   is_opaque = false,

   params = {
      plant_id = "string",
      plant_growth_stage = "number",
      plant_time_to_growth_days = "number"
   },

   on_stepped_on = function(self, params)
      -- >>>>>>>> shade2/action.hsp:768 			if feat(1)=objPlant{ ...
      local name = I18N.get("plant." .. self.plant_id .. ".plant_name")

      local stage = self.plant_growth_stage
      if stage == 0 then
         Gui.mes("action.move.feature.seed.growth.seed", name)
      elseif stage == 1 then
         Gui.mes("action.move.feature.seed.growth.bud", name)
      elseif stage == 2 then
         Gui.mes("action.move.feature.seed.growth.tree", name)
      else
         Gui.mes("action.move.feature.seed.growth.withered", name)
      end
      -- <<<<<<<< shade2/action.hsp:780 				} ...   end,
   end,

   events = {
      {
         id = "elona.on_harvest_plant",
         name = "Harvest plant.",
         callback = function(self, params)
            data["elona.plant"]:ensure(self.plant_id).on_harvest(self, params)
         end
      }
   }
}
