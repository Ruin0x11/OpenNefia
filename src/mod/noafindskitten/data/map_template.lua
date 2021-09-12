local InstancedMap = require("api.InstancedMap")
local Pos = require("api.Pos")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Feat = require("api.Feat")
local Rand = require("api.Rand")
local Input = require("api.Input")
local Anim = require("mod.elona_sys.api.Anim")
local Color = require("mod.extlibs.api.Color")
local Quest = require("mod.elona_sys.api.Quest")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local ElonaQuest = require("mod.elona.api.ElonaQuest")

data:add {
   _type = "base.chip",
   _id = "object",
   image = "mod/noafindskitten/graphic/object.png"
}

data:add {
   _type = "base.feat",
   _id = "object",

   params = {
      is_kitten = { type = types.boolean, default = false },
      description = { type = types.string }
   },

   image = "noafindskitten.object",
   is_solid = true,
   is_opaque = false,
   shadow_type = "normal",

   on_bumped_into = function(self, params)
      if self.params.is_kitten then
         local anim = Anim.load("elona.anim_smoke", self.x, self.y)
         Gui.start_draw_callback(anim)
         self.image = "elona.chara_stray_cat"
         self.color = {255, 255, 255}
         Gui.update_screen()
         Gui.mes("noafindskitten.kitten_found", "Green")
         Input.query_more()

         local quest = assert(Quest.get_immediate_quest())
         quest.state = "completed"

         ElonaQuest.travel_to_previous_map()
      else
         Gui.play_sound("base.chat")
         Gui.mes_c(self.params.description)
      end
      return "turn_end"
   end,
   on_bash = function(self)
      if not self.params.is_kitten then
         Gui.play_sound("base.bash1")
         self:remove_ownership()
         return "turn_end"
      end
   end,

   events = {}
}

local quest_noafindskitten = {
   _type = "base.map_archetype",
   _id = "quest_noafindskitten",

   starting_pos = MapEntrance.center,

   properties = {
      music = "elona.ruin",
      types = { "quest" },
      level = 1,
      is_indoor = true,
      max_crowd_density = 0,
      reveals_fog = true,
      is_temporary = true
   },
}

function quest_noafindskitten.on_generate_map(area, floor, params)
   local map = InstancedMap:new(40, 40)
   map:clear("elona.cobble")
   for _, x, y in Pos.iter_border(0, 0, map:width() - 1, map:height() - 1) do
      map:set_tile(x, y, "elona.wall_brick_top")
   end

   -- NOTE: we'd want to ensure there's a clear path to kitten, so the player doesn't get blocked.
   local count = math.floor(map:width() * map:height() / 40)
   for _=1, count do
      local object = Feat.create("noafindskitten.object", nil, nil, {params={description=I18N.get("noafindskitten.nki")}}, map)
      if object then
         object.color = {Color:new_hsl(Rand.rnd(360), 1, 0.8):to_rgb()}
      end
   end
   Rand.choice(Feat.iter(map):filter(function(i) return i._id == "noafindskitten.object" end)).params.is_kitten = true

   return map, "noafindskitten.noafindskitten"
end

data:add(quest_noafindskitten)
