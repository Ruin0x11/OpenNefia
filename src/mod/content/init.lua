--
--
-- Charas
--
--

data:add {
   _type = "base.chara",
   _id = "player",

   name = "player",
   race = "elona.norland",
   class = "elona.gunner",
   faction = "base.enemy",
   image = 4,
   max_hp = 50,
   max_mp = 10,

   body_parts = {
      "elona.head",
      "elona.neck",
      "elona.back",
      "elona.body",
      "elona.hand",
      "elona.hand",
      "elona.ring",
      "elona.ring",
      "elona.arm",
      "elona.arm",
      "elona.waist",
      "elona.leg",
      "elona.ranged",
      "elona.ammo"
   }
}

-- TODO: This must fail, since prototypes should only be modifiable in
-- transactions to support hotloading.
data["base.chara"]["content.player"].max_hp = 50

data:add {
   _type = "base.chara",
   _id = "ally",

   name = "ally",
   race = "elona.norland",
   class = "elona.gunner",
   faction = "base.enemy",
   image = 10,
   max_hp = 100,
   max_mp = 20,

   talk = "content.test"
}

data:add {
   _type = "base.chara",
   _id = "enemy",

   name = "enemy",
   race = "elona.norland",
   class = "elona.gunner",
   faction = "base.enemy",
   image = 50,
   max_hp = 10,
   max_mp = 2,

   body_parts = {
      "elona.head",
      "elona.neck",
      "elona.body",
      "elona.hand",
      "elona.ring",
      "elona.arm",
      "elona.waist",
      "elona.leg"
   }
}

--
--
-- Items
--
--

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
      "elona.body"
   }
}

data:add {
   _type = "base.item",
   _id = "ring",

   name = "ring",
   image = 19,

   equip_slots = {
      "elona.ring"
   }
}

data:add {
   _type = "base.item",
   _id = "arrow",

   name = "arrow",
   image = 20,

   equip_slots = {
      "elona.ammo"
   }
}

data:add {
   _type = "base.item",
   _id = "axe",

   name = "axe",
   image = 33,

   equip_slots = {
      "elona.hand"
   }
}

data:add {
   _type = "base.item",
   _id = "amulet",

   name = "amulet",
   image = 36,

   equip_slots = {
      "elona.neck"
   }
}

data:add {
   _type = "base.item",
   _id = "shoes",

   name = "shoes",
   image = 58,

   equip_slots = {
      "elona.leg"
   }
}


data:add {
   _type = "base.enchantment",
   _id = "increase_pv",

   wielder = {
      pv = 50
   }
}

--
--
-- Map tiles
--
--

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

--
--
-- Feats
--
--

data:add_multi(
   "base.sound",
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
            { talk = "「負けるもんか！」", voice = "content.voice5" },
            { talk = "「うしゃー、やるぞ！」"},
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
            { talk = "「よっ、よ！」"},
            { talk = "「うしゅっ」"},
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
               function(source, p)
                  local Map = require("api.Map")
                  if Map.is_in_fov(p.chara.x, p.chara.y) then
                     DamagePopup.add(p.chara.x, p.chara.y, tostring(p.damage))
                  end
               end,
               {priority=500000})


data:add {
   _type = "base.map_generator",
   _id = "test",

   generate = function(self, p)
      local InstancedMap = require("api.InstancedMap")
      local Map = require("api.Map")

      local width = p.width or 100
      local height = p.height or 100
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

local function my_start()
   local Chara = require("api.Chara")
   local Item = require("api.Item")
   local Feat = require("api.Feat")
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
      Item.create("content.test", 0, 0, {amount = 2}, Chara.player())
   end

   local armor = Item.create("content.armor")
   armor.curse_state = "blessed"
   Chara.player():equip_item(armor, true)
   Chara.player():refresh()
end

data:add {
   _type = "base.scenario",
   _id = "my_scenario",

   name = "My Scenario",

   starting_map = { generator = "elona_sys.elona122", params = { name = "sister" }},

   on_game_start = my_start
}

require("mod.content.dialog")

local Log = require("api.Log")
Log.set_level(3)

Event.register("base.hook_travel_to_map", "north tyris",
               function(source, params, result)
                  local Map = require("api.Map")
                  return {Map.generate("elona_sys.elona122", { name = "ntyris" })}
               end)
