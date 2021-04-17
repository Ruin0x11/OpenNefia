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
   }

data:add_multi("base.item", item)

require("mod.elona.data.item.book")
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
