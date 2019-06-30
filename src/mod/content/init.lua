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

data:add {
   _type = "base.feat",
   _id = "door",

   image = 194,
   is_solid = true,
   is_opaque = true,

   params = { opened = "boolean", open_sound = "string", close_sound = "string", opened_tile = "string", closed_tile = "string" },
   open_sound = "base.door1",
   close_sound = "base.door2",

   closed_tile = 194,
   opened_tile = 195,

   on_refresh = function(self)
      -- HACK
      self.opened = not not self.opened

      self:mod("can_open", not self.opened, "set")
      self:mod("can_close", self.opened, "set")
      self:mod("is_solid", not self.opened, "set")
      self:mod("is_opaque", not self.opened, "set")
      if self.opened then
         self:mod("image", self.opened_tile)
      else
         self:mod("image", self.closed_tile)
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

      if self.open_sound then
         local Gui = require("api.Gui")
         Gui.play_sound(self.open_sound, self.x, self.y)
      end

      self:refresh()
   end,
   on_close = function(self, chara)
      if not self.opened then
         return
      end

      self.opened = false

      if self.close_sound then
         local Gui = require("api.Gui")
         Gui.play_sound(self.close_sound, self.x, self.y)
      end

      self:refresh()
   end
}

data:add {
   _type = "base.feat",
   _id = "stair",

   image = 196,
   is_solid = false,
   is_opaque = false,

   params = { generator = "string", generator_params = "table", map_uid = "number" },

   on_refresh = function(self)
      self:mod("can_activate", true)
   end,

   on_activate = function(self, chara)
      if not chara:is_player() then
         return
      end

      local Gui = require("api.Gui")
      local Map = require("api.Map")

      local map
      if self.map_uid == nil then
         local err
         map, err = Map.generate(self.generator, self.generator_params)
         if err then
            Gui.mes("Couldn't load map: " .. err)
            return "player_turn_query"
         end
      end

      Gui.play_sound("base.exitmap1")
      Map.travel_to(map)

      return "player_turn_query"
   end
}

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
            { talk = "「負けるもんか！」"},
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

Event.register("base.on_game_start",
               "game start",
               function()
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

                  Feat.create("content.door", 11, 11)

                  local stair = Feat.create("content.stair", 12, 11)
                  stair.generator = "elona_sys.elona122"
                  stair.generator_params = { name = "sister" }
end)

require("mod.content.dialog")

local Log = require("api.Log")
Log.set_level(4)

data["base.chara"]:edit("test edit",
   function(chara)
      chara.image = 3
   end
)
