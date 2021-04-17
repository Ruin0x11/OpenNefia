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
require("mod.elona.data.item.junk")
require("mod.elona.data.item.ore")
require("mod.elona.data.item.potion")
require("mod.elona.data.item.rod")
require("mod.elona.data.item.scroll")
require("mod.elona.data.item.spellbook")
require("mod.elona.data.item.tool")
require("mod.elona.data.item.tree")
