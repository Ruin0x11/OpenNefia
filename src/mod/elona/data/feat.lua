local Gui = require("api.Gui")
local Item = require("api.Item")
local Map = require("api.Map")
local MapArea = require("api.MapArea")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local ElonaAction = require("mod.elona.api.ElonaAction")

data:add {
   _type = "base.feat",
   _id = "door",

   elona_id = 21,
   image = "elona.feat_door_wooden_closed",
   is_solid = true,
   is_opaque = true,

   params = { opened = "boolean", open_sound = "string", close_sound = "string", opened_tile = "string", closed_tile = "string" },
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
         map_uid = "number"
      },

      on_refresh = function(self)
         self:mod("can_activate", true)
      end,

      on_activate = function(self, chara)
         if not chara:is_player() then
            return
         end

         local success, map = MapArea.load_map_of_entrance(self)
         if not success then
            Gui.report_error(map)
            return "player_turn_query"
         end

         Gui.play_sound("base.exitmap1")
         Map.travel_to(map)

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
            local basher = params.chara
            -- TODO: spill fragment
            Item.create("elona.pillar", self.x, self.y)
            if Map.is_in_fov(basher.x, basher.y) then
               Gui.play_sound("base.bash1")
               Gui.mes(basher.uid ..  " shatters the pot.")
               Gui.play_sound("base.crush1")
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
