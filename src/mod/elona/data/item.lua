local Map = require("api.Map")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Item = require("api.Item")
local Rand = require("api.Rand")
local ElonaMagic = require("mod.elona.api.ElonaMagic")
local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local ItemMaterial = require("mod.elona.api.ItemMaterial")
local Skill = require("mod.elona_sys.api.Skill")
local ItemFunction = require("mod.elona.api.ItemFunction")
local Calc = require("mod.elona.api.Calc")
local Building = require("mod.elona.api.Building")
local I18N = require("api.I18N")
local Magic = require("mod.elona_sys.api.Magic")
local Input = require("api.Input")
local Log = require("api.Log")
local Chara = require("api.Chara")
local Pos = require("api.Pos")
local Anim = require("mod.elona_sys.api.Anim")
local World = require("api.World")
local Weather = require("mod.elona.api.Weather")
local Area = require("api.Area")
local ElonaItem = require("mod.elona.api.ElonaItem")
local Filters = require("mod.elona.api.Filters")
local SkillCheck = require("mod.elona.api.SkillCheck")
local Const = require("api.Const")
local Charagen = require("mod.elona.api.Charagen")
local Mef = require("api.Mef")
local Hunger = require("mod.elona.api.Hunger")
local ProductionMenu = require("mod.elona.api.gui.ProductionMenu")
local Inventory = require("api.Inventory")
local light = require("mod.elona.data.item.light")

-- TODO: Some fields should not be stored on the prototype as
-- defaults, but instead copied on generation.

-- IMPORTANT: Fields like "on_throw", "on_drink", "on_use" and similar are tied
-- to event handlers that are dynamically generated in elona_sys.events. See the
-- "Connect item events" handler there for details.

local item =
   {
      {
         _id = "bug",
         elona_id = 0,
         image = "elona.item_worthless_fake_gold_bar",
         value = 1,
         weight = 1,
         fltselect = 1,
         category = 99999999,
         subcategory = 99999999,
         coefficient = 100,
         categories = {
            "elona.bug",
            "elona.no_generate"
         },
         light = light.item,
         is_wishable = false
      },
      {
         _id = "book_unreadable",
         elona_id = 23,
         image = "elona.item_book",
         value = 100,
         weight = 80,
         on_read = function(self)
            -- >>>>>>>> shade2/proc.hsp:1254 	item_identify ci,knownName ..
            Effect.identify_item(self, Enum.IdentifyState.Name)
            local BookMenu = require("api.gui.menu.BookMenu")
            BookMenu:new("text", true):query()
            return "player_turn_query"
            -- >>>>>>>> shade2/proc.hsp:1254 	item_identify ci,knownName ..
         end,
         fltselect = 1,
         category = 55000,
         coefficient = 100,
         is_wishable = false,

         param1 = 1,
         elona_type = "normal_book",
         categories = {
            "elona.book",
            "elona.no_generate"
         }
      },
      {
         _id = "book",
         elona_id = 24,
         image = "elona.item_book",
         value = 500,
         weight = 80,
         on_read = function(self)
            -- >>>>>>>> shade2/proc.hsp:1254 	item_identify ci,knownName ..
            Effect.identify_item(self, Enum.IdentifyState.Name)
            local text = I18N.get("_.elona.book." .. self.params.book_id .. ".text")
            local BookMenu = require("api.gui.menu.BookMenu")
            BookMenu:new(text, true):query()
            return "player_turn_query"
            -- >>>>>>>> shade2/proc.hsp:1254 	item_identify ci,knownName ..
         end,
         category = 55000,
         rarity = 2000000,
         coefficient = 100,

         params = { book_id = nil },

         on_init_params = function(self)
            -- >>>>>>>> shade2/item.hsp:618 	if iId(ci)=idBook	:if iBookId(ci)=0:iBookId(ci)=i ..
            if not self.params.book_id then
               local cands = data["elona.book"]:iter()
               :filter(function(book) return book.is_randomly_generated end)
                  :extract("_id")
                  :to_list()
               self.params.book_id = Rand.choice(cands)
            end
            -- <<<<<<<< shade2/item.hsp:618 	if iId(ci)=idBook	:if iBookId(ci)=0:iBookId(ci)=i ..
         end,

         elona_type = "normal_book",

         prevent_sell_in_own_shop = true,

         categories = {
            "elona.book"
         }
      },
      {
         _id = "bugged_book",
         elona_id = 25,
         image = "elona.item_book",
         value = 100,
         weight = 80,
         fltselect = 1,
         category = 55000,
         coefficient = 100,

         param1 = 2,
         elona_type = "normal_book",
         categories = {
            "elona.book",
            "elona.no_generate"
         }
      },
      {
         _id = "broken_vase",
         elona_id = 46,
         image = "elona.item_broken_vase",
         value = 6,
         weight = 800,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,
         categories = {
            "elona.junk",
            "elona.junk_in_field"
         }
      },
      {
         _id = "washing",
         elona_id = 47,
         image = "elona.item_washing",
         value = 140,
         weight = 250,
         category = 64000,
         subcategory = 64100,
         coefficient = 100,
         categories = {
            "elona.junk_town",
            "elona.junk"
         }
      },
      {
         _id = "bonfire",
         elona_id = 48,
         image = "elona.item_bonfire",
         value = 170,
         weight = 3200,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         },
         light = light.torch_lamp
      },
      {
         _id = "flag",
         elona_id = 49,
         image = "elona.item_flag",
         value = 130,
         weight = 1400,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "broken_sword",
         elona_id = 50,
         image = "elona.item_broken_sword",
         value = 10,
         weight = 1050,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,
         categories = {
            "elona.junk",
            "elona.junk_in_field"
         }
      },
      {
         _id = "bone_fragment",
         elona_id = 51,
         image = "elona.item_bone_fragment",
         value = 10,
         weight = 80,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,
         categories = {
            "elona.junk",
            "elona.junk_in_field"
         }
      },
      {
         _id = "skeleton",
         elona_id = 52,
         image = "elona.item_skeleton",
         value = 10,
         weight = 80,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "tombstone",
         elona_id = 53,
         image = "elona.item_tombstone",
         value = 10,
         weight = 12000,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "ore_piece",
         elona_id = 214,
         image = "elona.item_ore_piece",
         value = 180,
         weight = 12000,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,

         random_color = "Furniture",

         categories = {
            "elona.junk",
            "elona.junk_in_field"
         }
      },
      {
         _id = "lot_of_empty_bottles",
         elona_id = 215,
         image = "elona.item_whisky",
         value = 10,
         weight = 220,
         category = 64000,
         subcategory = 64100,
         coefficient = 100,
         originalnameref2 = "lot",
         random_color = "Furniture",
         categories = {
            "elona.junk_town",
            "elona.junk"
         }
      },
      {
         _id = "basket",
         elona_id = 216,
         image = "elona.item_basket",
         value = 40,
         weight = 80,
         category = 64000,
         coefficient = 100,
         tags = { "fest" },
         random_color = "Furniture",
         categories = {
            "elona.tag_fest",
            "elona.junk"
         }
      },
      {
         _id = "empty_bowl",
         elona_id = 217,
         image = "elona.item_empty_bowl",
         value = 25,
         weight = 90,
         category = 64000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "bowl",
         elona_id = 218,
         image = "elona.item_bowl",
         value = 30,
         weight = 80,
         category = 64000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "straw",
         elona_id = 221,
         image = "elona.item_straw",
         value = 7,
         weight = 70,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "animal_bone",
         elona_id = 222,
         image = "elona.item_animal_bone",
         value = 8,
         weight = 40,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,
         categories = {
            "elona.junk",
            "elona.junk_in_field"
         }
      },
      {
         _id = "fire_wood",
         elona_id = 273,
         image = "elona.item_fire_wood",
         value = 10,
         weight = 1500,
         category = 64000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "scarecrow",
         elona_id = 274,
         image = "elona.item_scarecrow",
         value = 10,
         weight = 4800,
         category = 64000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "broom",
         elona_id = 275,
         image = "elona.item_broom",
         value = 100,
         weight = 800,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "large_bouquet",
         elona_id = 301,
         image = "elona.item_large_bouquet",
         value = 240,
         weight = 1400,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "stump",
         elona_id = 330,
         image = "elona.item_stump",
         value = 250,
         weight = 3500,
         category = 64000,
         coefficient = 100,

         elona_function = 44,

         categories = {
            "elona.junk"
         }
      },
      {
         _id = "remains_skin",
         elona_id = 337,
         image = "elona.item_rabbits_tail",
         value = 100,
         weight = 1500,
         category = 62000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains"
         }
      },
      {
         _id = "remains_blood",
         elona_id = 338,
         image = "elona.item_remains_blood",
         value = 100,
         weight = 1500,
         category = 62000,
         rarity = 200000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains"
         }
      },
      {
         _id = "remains_eye",
         elona_id = 339,
         image = "elona.item_remains_eye",
         value = 100,
         weight = 1500,
         category = 62000,
         rarity = 400000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains"
         }
      },
      {
         _id = "remains_heart",
         elona_id = 340,
         image = "elona.item_remains_heart",
         value = 100,
         weight = 1500,
         category = 62000,
         rarity = 100000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains"
         }
      },
      {
         _id = "remains_bone",
         elona_id = 341,
         image = "elona.item_remains_bone",
         value = 100,
         weight = 1500,
         category = 62000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains"
         }
      },
      {
         _id = "figurine",
         elona_id = 503,
         image = "elona.item_figurine",
         value = 1000,
         weight = 2500,
         fltselect = 1,
         category = 62000,
         rarity = 100000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains",
            "elona.no_generate"
         },
      },
      {
         _id = "card",
         elona_id = 504,
         image = "elona.item_card",
         value = 500,
         weight = 200,
         fltselect = 1,
         category = 62000,
         rarity = 100000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains",
            "elona.no_generate"
         }
      },
      {
         _id = "textbook",
         elona_id = 563,
         image = "elona.item_textbook",
         value = 4800,
         weight = 80,
         category = 55000,
         rarity = 50000,
         coefficient = 100,

         params = { textbook_skill_id = nil },
         on_init_params = function(self, params)
            -- >>>>>>>> shade2/item.hsp:619 	if iId(ci)=idBookSkill	:if iBookId(ci)=0:iBookId( ..
            self.params.textbook_skill_id = Skill.random_skill()
            -- <<<<<<<< shade2/item.hsp:619 	if iId(ci)=idBookSkill	:if iBookId(ci)=0:iBookId( ..
         end,

         on_read = function(self, params)
            -- >>>>>>>> shade2/command.hsp:4447 	if iId(ci)=idBookSkill{ ...
            local skill_id = self.params.textbook_skill_id
            local chara = params.chara
            if chara:is_player() and not chara:has_skill(skill_id) then
               Gui.mes("action.read.book.not_interested")
               if not Input.yes_no() then
                  return "player_turn_query"
               end
            end

            chara:start_activity("elona.training", {skill_id=skill_id,item=self})

            return "turn_end"
            -- <<<<<<<< shade2/command.hsp:4454 		} ...         end,
         end,

         elona_type = "normal_book",

         categories = {
            "elona.book"
         }
      },
      {
         _id = "shit",
         elona_id = 575,
         image = "elona.item_shit",
         value = 25,
         weight = 80,
         category = 64000,
         rarity = 250000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "snow_scarecrow",
         elona_id = 590,
         image = "elona.item_snow_scarecrow",
         value = 10,
         weight = 4800,
         category = 64000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "bait",
         elona_id = 617,
         image = "elona.item_bait_water_flea",
         value = 1000,
         weight = 250,
         fltselect = 1,
         category = 64000,
         coefficient = 100,

         on_dip_into = function(self, params)
            -- >>>>>>>> shade2/action.hsp:1600 	if iId(ciDip)=idBite{	 ...
            local target_item = params.target_item
            target_item = target_item:separate()
            self:remove(1)
            Gui.play_sound("base.equip1")
            Gui.mes("action.dip.result.bait_attachment", target_item:build_name(), self:build_name(1))

            if target_item.params.bait_type == self.params.bait_type then
               target_item.params.bait_amount = target_item.params.bait_amount + Rand.rnd(10) + 15
            else
               target_item.params.bait_amount = Rand.rnd(10) + 15
               target_item.params.bait_type = self.params.bait_type
            end

            return "turn_end"
            -- <<<<<<<< shade2/action.hsp:1605 		} ..
         end,

         params = { bait_type = "elona.water_flea" },

         on_init_params = function(self)
            -- >>>>>>>> shade2/item.hsp:638:DONE 	if iId(ci)=idBite{ ..
            self.params.bait_type = Rand.choice {
               "elona.water_flea",
               "elona.grasshopper",
               "elona.ladybug",
               "elona.dragonfly",
               "elona.locust",
               "elona.beetle",
            }

            local proto = data["elona.bait"]:ensure(self.params.bait_type)
            self.image = proto.image or self.image

            self.value = proto.value or proto.rank * proto.rank * 500 + 200
            -- <<<<<<<< shade2/item.hsp:642 		} ..
         end,

         categories = {
            "elona.no_generate",
            "elona.junk"
         },

         events = {
            {
               id = "elona_sys.calc_item_can_dip_into",
               name = "Bait dipping",

               callback = function(self, params)
                  return params.item._id == "elona.fishing_pole"
               end
            },
         },
      },
      {
         _id = "monster_heart",
         elona_id = 663,
         image = "elona.item_monster_heart",
         value = 25000,
         weight = 2500,
         fltselect = 3,
         category = 64000,
         rarity = 800000,
         coefficient = 100,

         is_precious = true,
         quality = Enum.Quality.Unique,
         categories = {
            "elona.unique_item",
            "elona.junk"
         },
         light = light.item
      },
      {
         _id = "book_of_rachel",
         elona_id = 668,
         image = "elona.item_book",
         value = 4000,
         weight = 80,
         category = 55000,
         rarity = 50000,
         coefficient = 0,

         params = { book_of_rachel_number = 1 },
         on_init_params = function(self)
            self.params.book_of_rachel_number = Rand.rnd(4) + 1
         end,

         on_read = function(self)
            -- >>>>>>>> shade2/proc.hsp:1250 	if iId(ci)=idDeedVoid: :snd seOpenBook: txt lang( ...
            Gui.play_sound("base.book1")
            Gui.mes("action.read.book.book_of_rachel")
            return "turn_end"
            -- <<<<<<<< shade2/proc.hsp:1250 	if iId(ci)=idDeedVoid: :snd seOpenBook: txt lang( ..
         end,

         elona_type = "normal_book",

         tags = { "noshop" },

         categories = {
            "elona.book",
            "elona.tag_noshop"
         }
      },
      {
         _id = "town_book",
         elona_id = 700,
         image = "elona.item_town_book",
         value = 750,
         weight = 20,
         on_read = function()
            -- menucycle = 1,
            -- show_city_chart(),
         end,
         category = 55000,
         rarity = 20000,
         coefficient = 0,
         categories = {
            "elona.book"
         }
      },
      {
         _id = "book_of_bokonon",
         elona_id = 747,
         image = "elona.item_book",
         value = 4000,
         weight = 80,
         fltselect = 1,
         category = 55000,
         rarity = 50000,
         coefficient = 0,
         originalnameref2 = "book",

         param1 = 1,

         params = { book_of_bokonon_no = 1 },
         on_init_params = function(self)
            self.params.book_of_bokonon_no = Rand.rnd(4) + 1
         end,

         elona_type = "normal_book",

         tags = { "noshop" },

         categories = {
            "elona.book",
            "elona.tag_noshop",
            "elona.no_generate"
         }
      },
   }

data:add_multi("base.item", item)

require("mod.elona.data.item.cargo")
require("mod.elona.data.item.container")
require("mod.elona.data.item.currency")
require("mod.elona.data.item.equip")
require("mod.elona.data.item.fish")
require("mod.elona.data.item.food")
require("mod.elona.data.item.furniture")
require("mod.elona.data.item.ore")
require("mod.elona.data.item.potion")
require("mod.elona.data.item.rod")
require("mod.elona.data.item.scroll")
require("mod.elona.data.item.spellbook")
require("mod.elona.data.item.tool")
require("mod.elona.data.item.tree")
