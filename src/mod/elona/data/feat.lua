local Gui = require("api.Gui")
local Item = require("api.Item")
local Log = require("api.Log")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local ElonaAction = require("mod.elona.api.ElonaAction")
local SkillCheck = require("mod.elona.api.SkillCheck")
local Chara = require("api.Chara")
local Itemgen = require("mod.tools.api.Itemgen")
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

local function get_map_display_name(area, description)
   if area.is_hidden then
      return ""
   end

   local desc = I18N.get("map.unique." .. area.gen_id .. ".desc")
   local name = I18N.get("map.unique." .. area.gen_id .. ".name")
   if name == nil and desc then
      name = desc
   end

   if not description then
      return name
   end

   local text
   if area.types["elona.nefia"] then
      text = I18N.get("map.you_see_an_entrance", name, area.starting_dungeon_level)
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
   on_bumped_into = function(self, params) self:on_open(params) end,

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
      local basher = params.chara
      Gui.play_sound("base.bash1")
      local difficulty = self.difficulty * 3 + 30

      local str = basher:skill_level("elona.stat_strength")

      if Rand.rnd(difficulty) < str and Rand.one_in(2) then
         Gui.mes("Door is destroyed.")
         if self.difficulty > str then
            Skill.gain_skill_action("elona.stat_strength", (difficulty - str) * 15)
         end
         self:remove_ownership()
         return "turn_end"
      else
         Gui.mes("Door is bashed.")

         if Rand.one_in(4) then Gui.mes("magic1") end
         if Rand.one_in(3) then Gui.mes("magic2") end
         if Rand.one_in(3) then Gui.mes("hurtself", "Purple") end
         if Rand.one_in(3) then
            if self.difficulty > 0 then
               self.difficulty = self.difficulty - 1
               Gui.mes_visible("The door cracks.", basher.x, basher.y)
            end
         end
      end

      return "turn_end"
   end,
   events = {
      {
         id = "base.on_build_feat",
         name = "Set difficulty.",
         callback = function(self) self.difficulty = 5 end
      }
   }
}


local function entrance_in_parent_map(map, chara, prev)
   local x, y
   local prev_area = Area.for_map(prev)
   local find_area_entrance = function(feat)
      return feat.params.area_uid == prev_area.uid
   end
   local entrance = map:iter_feats():filter(find_area_entrance):nth(1)
   if entrance == nil then
      return nil
   else
      x = entrance.x
      y = entrance.y
   end

   local index = 0
   for i, c in Chara.iter_allies() do
      if c.uid == chara.uid then
         index = i
         break
      end
   end

   return { x = x + Rand.rnd(math.floor(index / 5) + 1), y = y + Rand.rnd(math.floor(index / 5) + 1) }
end

local function travel(start_pos_fn)
   return function(self, params)
      local chara = params.chara
      if not chara:is_player() then return end

      Gui.play_sound("base.exitmap1")

      local area = Area.get(self.params.area_uid)
      if area == nil then
         Log.error("Missing area with UID '%d'", self.params.area_uid)
         return "player_turn_query"
      end

      local ok, map = area:load_or_generate_floor(self.params.area_floor)
      if not ok then
         local err = map
         if err == "no_archetype" then
            Log.error("Area does not specify an archetype, so there is no way to know what kind of map should be generated. Use InstancedArea:set_archetype(archetype_id) to set one.")
         else
            error(("Missing map with floor number '%d' in area '%d' (%s)"):format(self.params.area_floor, area.uid, err))
         end
         return "player_turn_query"
      end

      local prev_map = self:current_map()
      local prev_area = Area.for_map(prev_map)
      local starting_pos

      -- >>>>>>>> shade2/map.hsp:152 		if feat(1)=objDownstairs :msgTemp+=lang("階段を降りた。 ..
      if area.uid ~= prev_area.uid then
         -- If the area we're trying to travel to is the parent of this area, then
         -- put the player directly on the area's entrance.
         if Area.parent(prev_area) == area then
            -- TODO allow configuring ally start positions in Map.travel_to() (mStartWorld)
            starting_pos = entrance_in_parent_map(map, chara, prev_map)
            if starting_pos == nil then
               -- Assume there will be stairs in the connecting map.
               starting_pos = start_pos_fn(map, chara, prev_map, self)
            end
         else
            -- We're going into a dungeon. Always assume there's stairs there.
            -- TODO: allow maps to declare arbitrary start positions.
            starting_pos = start_pos_fn(map, chara, prev_map, self)
         end
      else
         starting_pos = start_pos_fn(map, chara, prev_map, self)
      end

      local start_x, start_y
      if starting_pos.x and starting_pos.y then
         start_x = starting_pos.x
         start_y = starting_pos.y
      end
      -- <<<<<<<< shade2/map.hsp:153 		if feat(1)=objUpstairs	 :msgTemp+=lang("階段を昇った。" ..

      local travel_params = {
         feat = self,
         start_x = start_x,
         start_y = start_y
      }

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
         Gui.mes_c(("This leads to: %s %s"):format(self.params.area_uid, self.params.area_floor))
      end,

      on_activate = travel(start_pos_fn),

      [field] = function(self, params) self:on_activate(params.chara) end
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

   on_activate = travel(MapEntrance.stairs_up),

   on_stepped_on = function(self, params)
      local area = { gen_id = "elona.vernis", types = {} }
      if area.types["elona.nefia"] then
         -- TODO
         ExHelp.maybe_show("elona.random_dungeon")
      end
   end,

   description = function(self)
      local area = { gen_id = "elona.vernis", types = {} }
      return get_map_display_name(area, true)
   end,

   on_descend = function(self, params) self:on_activate(params.chara) end
}

data:add {
   _type = "base.feat",
   _id = "pot",
   elona_id = 30,

   image = "elona.feat_pot",
   is_solid = false,
   is_opaque = false,

   params = {},

   on_bash = function(self, params)
      local map = self:current_map()
      local basher = params.chara

      self.image = nil

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

   on_search = function(self, params)
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
}

local function visit_quest_giver(feat, player, quest)
   local client = Chara.find(quest.client_uid, "all", feat:current_map())
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

      return visit_quest_giver(self, params.chara, quest)
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

   on_search = function(self, params)
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
