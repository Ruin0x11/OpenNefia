local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")

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
   image = "elona.chara_rabbit",
   level = 1,
   max_hp = 50,
   max_mp = 10,
   rarity = 0,
   coefficient = 400,

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
   image = "elona.chara_snail",
   level = 1,
   max_hp = 100,
   max_mp = 20,
   max_stamina = 10000,
   rarity = 0,
   coefficient = 0,

   talk = "content.test"
}

data:add {
   _type = "base.chara",
   _id = "enemy",

   name = "enemy",
   race = "elona.norland",
   class = "elona.gunner",
   faction = "base.enemy",
   image = "elona.chara_kobold",
   level = 1,
   max_hp = 10,
   max_mp = 2,
   rarity = 0,
   coefficient = 0,

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
   image = "elona.item_melon",
}

data:add {
   _type = "base.item",
   _id = "armor",

   name = "armor",
   image = "elona.item_armored_cloak",

   equip_slots = {
      "elona.body"
   }
}

data:add {
   _type = "base.item",
   _id = "ring",

   name = "ring",
   image = "elona.item_engagement_ring",

   equip_slots = {
      "elona.ring"
   }
}

data:add {
   _type = "base.item",
   _id = "bow",

   name = "bow",
   image = "elona.item_long_bow",
   skill = "elona.bow",

   dice_x = 10,
   dice_y = 10,

   equip_slots = {
      "elona.ranged"
   }
}

data:add {
   _type = "base.item",
   _id = "arrow",

   name = "arrow",
   image = "elona.item_bolt",
   skill = "elona.bow",

   equip_slots = {
      "elona.ammo"
   }
}

data:add {
   _type = "base.item",
   _id = "axe",

   name = "axe",
   image = "elona.item_hand_axe",
   skill = "elona.axe",

   dice_x = 10,
   dice_y = 10,

   equip_slots = {
      "elona.hand"
   }
}

data:add {
   _type = "base.item",
   _id = "amulet",

   name = "amulet",
   image = "elona.item_neck_guard",

   equip_slots = {
      "elona.neck"
   }
}

data:add {
   _type = "base.item",
   _id = "shoes",

   name = "shoes",
   image = "elona.item_heavy_boots",

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

   image = "mod/base/graphic/floor.png",
   is_solid = false,
   is_opaque = false
}

data:add {
   _type = "base.map_tile",
   _id = "wall",

   image = "mod/base/graphic/floor.png",
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
            { talk = "「負けるもんか！」" },
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
local Rand = require("api.Rand")


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

Event.register("elona.on_physical_attack_miss",
               "damage popups",
               function(source, p)
                  local Map = require("api.Map")
                  if Map.is_in_fov(p.target.x, p.target.y) then
                     if p.hit == "evade" then
                        DamagePopup.add(p.target.x, p.target.y, "evade!!")
                     else
                        DamagePopup.add(p.target.x, p.target.y, "miss")
                     end
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
      local map = InstancedMap:new(width, height, nil, "elona.cyber_4")

      for y=0,width-1 do
         for x=0,height-1 do
            if x == 0 or y == 0 or x == width-1 or y == height-1 then
               map:set_tile(x, y, "elona.wall_stone_7_top")
            elseif y % 3 == 0 or x % 4 == 1 then
               map:set_tile(x, y, Rand.choice({"elona.cyber_1", "elona.cyber_2", "elona.cyber_3"}))
            end
         end
      end

      map.player_start_pos = { x = math.floor(width / 2), y = math.floor(height / 2)}
      map.default_tile = "elona.tiled_1"

      return map, "test"
   end
}

local Chara = require("api.Chara")
local Item = require("api.Item")
local Map = require("api.Map")
local MapArea = require("api.MapArea")

local load_map = function(world_map, id)
   local find_home = function(i)
      return i.generator_params.generator == "elona_sys.map_template"
         and i.generator_params.params.id == id
   end
   local home_entrance = MapArea.iter_map_entrances("not_generated", world_map):filter(find_home):nth(1)
   assert(home_entrance)

   local success, map = MapArea.load_map_of_entrance(home_entrance, false)
   if not success then
      error(map)
   end
   return map
end

local Skill = require("mod.elona_sys.api.Skill")

local function base_init(self, player)
   do
      local success, world_map
      success, world_map = Map.generate("elona_sys.map_template", { id = "elona.north_tyris" })
      if not success then
         error(world_map)
      end

      -- TODO set this up automatically, as "root map" or similar
      local area = save.base.area_mapping:create_area()
      save.base.area_mapping:add_map_to_area(area.uid, world_map.uid)

      local home = load_map(world_map, "elona.your_home")
      --local vernis = load_map(world_map, "elona.vernis")
      --local palmia = load_map(world_map, "elona.palmia")
      --local lesimas = load_map(world_map, "elona.lesimas")

      Map.save(world_map)
      Map.save(home)
      --Map.save(vernis)
      --Map.save(palmia)
      --Map.save(lesimas)

      Map.set_map(home)

      assert(Map.current():take_object(player, 15, 12))
      Chara.set_player(player)
   end

   local armor = Item.create("content.armor", nil, nil, {}, player)
   armor.curse_state = "blessed"
   assert(player:equip_item(armor))

   local axe = Item.create("content.axe", nil, nil, {}, player)
   assert(player:equip_item(axe))

   local bow = Item.create("content.bow", nil, nil, {}, player)
   assert(player:equip_item(bow))

   local arrow = Item.create("content.arrow", nil, nil, {}, player)
   assert(player:equip_item(arrow))

   player:refresh()
end

local function my_start(self, player)
   config["base.play_music"] = false
   base_init(self, player)

   for i=1,4 do
      local a = Chara.create("elona.younger_sister", i+8, 3)
      a:recruit_as_ally()
      for _ = 1, 5 do
         Skill.gain_level(a)
         Skill.grow_primary_skills(a)
      end
      a:heal_to_max()
   end

   -- DeferredEvent.add(function()
   --       local lomias = Chara.find("elona.lomias", "others")
   --       Dialog.start(lomias, "elona.lomias_game_begin")

   --       return "player_turn_query"
   -- end)

   for _=1,10 do
      local c = Chara.create("elona.putit")
      c.is_not_targeted_by_ai = true
   end

   for _=1,50 do
      Item.create("content.test", 0, 0, {amount = 2}, Chara.player())
   end

   local function set_pcc(chara)
      chara.pcc = require("api.gui.Pcc"):new {
         {
            id = "elona.body_1",
            z_order = 0,
         },
         {
            id = "elona.eye_7",
            z_order = 10,
         },
         {
            id = "elona.hair_2",
            z_order = 20,
         },
         {
            id = "elona.cloth_1",
            z_order = 30,
         },
         {
            id = "elona.pants_1",
            z_order = 20,
         }
                                              }
      chara.pcc.dir = 4
   end

   set_pcc(Chara.player())
end

local function init_bells(self, player)
   local _, m = Map.generate("content.test")
   Map.set_map(m)

   assert(Map.current():take_object(player, 15, 12))
   Chara.set_player(player)
   local bow = Item.create("content.bow", nil, nil, {}, player)
   assert(player:equip_item(bow))

   local arrow = Item.create("content.arrow", nil, nil, {}, player)
   assert(player:equip_item(arrow))
   player.gold = 1000000000
   player.platinum = 1000

   for _= 1, 100 do
      Skill.gain_level(player)
      Skill.grow_primary_skills(player)
   end
   player:heal_to_max()

   fun.range(10):each(function() Chara.create("elona.silver_bell") end)
end


data:add {
   _type = "base.scenario",
   _id = "my_scenario",

   name = "My Scenario",

   on_game_start = my_start
}

require("mod.content.dialog")
