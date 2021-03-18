local Map = require("api.Map")
local SokobanMap = require("mod.sokoban.api.SokobanMap")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Quest = require("mod.elona_sys.api.Quest")
local ElonaQuest = require("mod.elona.api.ElonaQuest")
local Event = require("api.Event")
local Chara = require("api.Chara")
local Rand = require("api.Rand")

data:add {
   _type = "base.feat",
   _id = "barrel",

   params = {},

   image = "elona.item_barrel",
   is_solid = true,
   is_opaque = false,
   shadow_type = "normal",

   on_bumped_into = function(self, params)
      local dx = self.x - params.chara.x
      local dy = self.y - params.chara.y

      local new_x = self.x + dx
      local new_y = self.y + dy

      local map = self:current_map()
      local on_cell = Chara.at(new_x, new_y, map)
      if on_cell and on_cell:is_in_player_party() then
         local x, y = Map.find_position_for_chara(Rand.rnd(map:width()), Rand.rnd(map:height()), nil, map)
         if x then
            on_cell:set_pos(x, y)
         end
      end

      if Map.can_access(new_x, new_y, map) then
         self:set_pos(new_x, new_y)
      end

      if SokobanMap.is_solved(map) then
         Gui.update_screen()
         Gui.play_sound("base.complete1")
         Gui.mes_c("sokoban.solved", "Green")
         Input.query_more()

         local quest = assert(Quest.get_immediate_quest())
         quest.state = "completed"

         ElonaQuest.travel_to_previous_map()
      end

      return "turn_end"
   end,

   events = {}
}

local quest_sokoban = {
   _type = "base.map_archetype",
   _id = "quest_sokoban",

   properties = {
      music = "elona.ruin",
      types = { "quest" },
      level = 1,
      is_indoor = true,
      max_crowd_density = 0,
      reveals_fog = true,
      prevents_teleport = true,
      prevents_mining = true,
      is_temporary = true
   },
}

local function prevent_diagonal_movement(chara, params)
   if not chara:is_player() then
      return
   end

   local map = chara:current_map()
   if map._archetype ~= "sokoban.quest_sokoban" then
      return
   end

   local dx = params.x - params.prev_x
   local dy = params.y - params.prev_y
   if dx ~= 0 and dy ~= 0 then
      Gui.mes_duplicate()
      Gui.mes("sokoban.no_diagonal_movement")
      return { blocked = true }
   end
end
Event.register("base.before_chara_moved", "Prevent diagonal movement in sokoban", prevent_diagonal_movement)

data:add(quest_sokoban)
