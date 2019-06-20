data:add {
   _type = "base.chara",
   _id = "player",

   name = "player",
   image = 4,
   max_hp = 50,
   max_mp = 10
}

data:add {
   _type = "base.chara",
   _id = "ally",

   name = "ally",
   image = 10,
   max_hp = 100,
   max_mp = 20
}

data:add {
   _type = "base.item",
   _id = "test",

   name = "test",
   image = 101,
}

data:add {
   _type = "base.chara",
   _id = "enemy",

   name = "enemy",
   image = 50,
   max_hp = 10,
   max_mp = 2
}

data:add {
   _type = "base.map_tile",
   _id = "floor",

   image = "graphic/temp/map_tile/1_207.png",
   is_solid = false,
   is_opaque = false
}

data:add {
   _type = "base.map_tile",
   _id = "wall",

   image = "graphic/temp/map_tile/1_399.png",
   is_solid = true,
   is_opaque = true
}

local Event = require("api.Event")

data:add {
   _type = "base.map_generator",
   _id = "test",

   generate = function(self, p)
      local InstancedMap = require("api.InstancedMap")
      local Map = require("api.Map")

      local width = p.width or 30
      local height = p.height or 50
      local map = InstancedMap:new(width, height)

      for y=0,width-1 do
         for x=0,height-1 do
            if x == 0 or y == 0 or x == width-1 or y == height-1 then
               map:set_tile(x, y, "base.wall")
            end
         end
      end

      map.player_start_pos = { x = math.floor(width / 2), y = math.floor(height / 2)}

      return map
   end
}

Event.register("base.on_game_start",
"game start",
function()
   local Chara = require("api.Chara")
   local Item = require("api.Item")
   for i=1,4 do
      local a = Chara.create("base.ally", i+8, 3)
      Chara.recruit_as_ally(a)
   end

   for i=1,2 do
      for j=1,1 do
         local i = Chara.create("base.enemy", i+8, j+11)
      end
   end

   Item.create("base.test", 10, 11)
end)
