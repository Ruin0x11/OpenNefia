data:add {
   _type = "base.chara",
   _id = "player",

   name = "player",
   faction = "base.enemy",
   image = 4,
   max_hp = 50,
   max_mp = 10,

   body_parts = {
      "content.chest"
   }
}

data:add {
   _type = "base.chara",
   _id = "ally",

   name = "ally",
   faction = "base.enemy",
   image = 10,
   max_hp = 100,
   max_mp = 20,

   talk = "base.test"
}

data:add {
   _type = "base.item",
   _id = "test",

   name = "test",
   image = 5,
}

data:add {
   _type = "base.item",
   _id = "armor",

   name = "armor",
   image = 143,

   equip_slots = {
      "content.chest"
   }
}

data:add {
   _type = "base.chara",
   _id = "enemy",

   name = "enemy",
   faction = "base.enemy",
   image = 50,
   max_hp = 10,
   max_mp = 2
}

data:add {
   _type = "base.body_part",
   _id = "chest",

   name = "Chest"
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

require("mod.content.sound")

data:add_multi("base.sound",
               {
                  _id = "voice1",
                  file = "sound/temp/voice1.wav"
               },
               {
                  _id = "voice2",
                  file = "sound/temp/voice2.wav"
               },
               {
                  _id = "voice3",
                  file = "sound/temp/voice3.wav"
               },
               {
                  _id = "voice4",
                  file = "sound/temp/voice4.wav"
               },
               {
                  _id = "voice5",
                  file = "sound/temp/voice5.wav"
               }
)

data:add {
   _type = "base.talk",
   _id = "test",

   messages = {
      jp = {
         ["event:base.on_chara_killed"] = {
            "「と、取り返しのつかない事を…取り返しのつかない事をしてしまった…」",
            "「自信があってやる訳じゃないのに」",
            ""
         },

         ["event:base.after_chara_damaged"] = {
            "Ow.",
            "Eek!",
            "It hurts.",
         },

         ["event:base.on_chara_revived"] = "I'm revived.",

         ["base.ai_aggro"] = {
            { talk = "「負けるもんか！」", voice = "base.voice5" },
            { talk = "「うしゃー、やるぞ！」", voice = "base.voice3" },
            "",
            "",
            "",
            "",
            "",
            "",
         },

         ["base.ai_calm"] = {
            "「誰だ？誰かが私を見ている」",
            "「悔しいけど…」",
            ""
         },

         ["base.ai_melee"] = {
            { talk = "「よっ、よ！」", voice = "base.voice2" },
            { talk = "「うしゅっ」", voice = "base.voice4" },
            "",
            "",
         }
      }
   }
}


local Event = require("api.Event")


-- local EmotionIcon = require("mod.emotion_icons.api.EmotionIcon")
--
-- data:add {
--    _type = "emotion_icons.emotion_icon",
--    _id = "paralysis",
--
--    image = "mod/content/graphic/paralysis.bmp"
-- }
--
-- EmotionIcon.install("base.default")


local DamagePopup = require("mod.damage_popups.api.DamagePopup")

DamagePopup.install()

Event.register("base.after_damage_hp",
"damage popups",
function(p)
   local Map = require("api.Map")
   if Map.is_in_fov(p.chara.x, p.chara.y) then
      DamagePopup.add(p.chara.x, p.chara.y, tostring(p.damage))
   end
end)


data:add {
   _type = "base.map_generator",
   _id = "test",

   generate = function(self, p)
      local InstancedMap = require("api.InstancedMap")
      local Map = require("api.Map")

      local width = p.width or 30
      local height = p.height or 50
      local map = InstancedMap:new(width, height, nil, "content.floor")

      for y=0,width-1 do
         for x=0,height-1 do
            if x == 0 or y == 0 or x == width-1 or y == height-1 then
               map:set_tile(x, y, "content.wall")
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
      local a = Chara.create("content.ally", i+8, 3)
      a:recruit_as_ally()
   end

   for i=1,2 do
      for j=1,1 do
         local i = Chara.create("content.enemy", i+8, j+11)
      end
   end

   for i=1,50 do
      Item.create("content.test", 0, 0, 1, {}, Chara.player())
   end

   Item.create("content.armor")

   Chara.player():equip_item(Item.create("content.armor"), true)
end)
