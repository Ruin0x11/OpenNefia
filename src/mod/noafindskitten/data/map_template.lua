local InstancedMap = require("api.InstancedMap")
local Pos = require("api.Pos")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Feat = require("api.Feat")
local Rand = require("api.Rand")
local Input = require("api.Input")
local Map = require("api.Map")
local Anim = require("mod.elona_sys.api.Anim")
local Color = require("mod.elona_sys.api.Color")

data:add {
   _type = "base.chip",
   _id = "object",
   image = "mod/noafindskitten/graphic/object.png"
}

data:add {
   _type = "base.feat",
   _id = "object",

   params = {
      is_kitten = "boolean",
      description = "string",
   },

   image = "noafindskitten.object",
   is_solid = true,
   is_opaque = false,
   shadow_type = "normal",

   on_bumped_into = function(self, params)
      if self.is_kitten then
         local anim = Anim.load("elona.anim_smoke", self.x, self.y)
         Gui.start_draw_callback(anim)
         self.image = "elona.chara_stray_cat"
         self.color = {255, 255, 255}
         Gui.update_screen()
         Gui.mes("noafindskitten.kitten_found", "Green")
         Input.query_more()
         self:current_map()._quest.state = "completed"
         local _, map = assert(Map.load(self:current_map()._outer_map))
         Map.travel_to(map)
      else
         Gui.play_sound("base.chat")
         Gui.mes_c(self.description)
      end
      return "turn_end"
   end,
   on_bash = function(self)
      if not self.is_kitten then
         Gui.play_sound("base.bash1")
         self:remove_ownership()
         return "turn_end"
      end
   end,

   events = {}
}

local function generate_map()
   local map = InstancedMap:new(40, 40)
   map:clear("elona.cobble")
   for _, x, y in Pos.iter_border(0, 0, map:width() - 1, map:height() - 1) do
      map:set_tile(x, y, "elona.wall_brick_top")
   end

   -- NOTE: we'd want to ensure there's a clear path to kitten, so the player doesn't get blocked.
   local count = math.floor(map:width() * map:height() / 40)
   for _=1, count do
      local object = Feat.create("noafindskitten.object", nil, nil, {}, map)
      if object then
         object.description = I18N.get("noafindskitten.nki")
         object.color = Color.hsv_to_rgb(Rand.rnd(256), 255, 255)
      end
   end
   Rand.choice(Feat.iter(map)).is_kitten = true

   return map, "noafindskitten.noafindskitten"
end

data:add {
   _type = "base.map_template",
   _id = "quest_noafindskitten",

   map = generate_map,

   copy = {
      music = "elona.ruin",
      types = { "quest" },
      player_start_pos = "base.center",
      level = 1,
      is_indoor = true,
      max_crowd_density = 0,
      reveals_fog = true
   },
}
