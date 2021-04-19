local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Gui = require("api.Gui")
local Input = require("api.Input")
local IItemTextbook = require("mod.elona.api.aspect.IItemTextbook")
local IItemBook = require("mod.elona.api.aspect.IItemBook")
local IItemBookOfRachel = require("mod.elona.api.aspect.IItemBookOfRachel")

--
-- Book
--

data:add {
   _type = "base.item",
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

   elona_type = "normal_book",
   categories = {
      "elona.book",
      "elona.no_generate"
   }
}

data:add {
   _type = "base.item",
   _id = "book",
   elona_id = 24,
   image = "elona.item_book",
   value = 500,
   weight = 80,
   category = 55000,
   rarity = 2000000,
   coefficient = 100,

   elona_type = "normal_book",

   prevent_sell_in_own_shop = true,

   categories = {
      "elona.book"
   },

   _ext = {
      IItemBook
   }
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
   _id = "textbook",
   elona_id = 563,
   image = "elona.item_textbook",
   value = 4800,
   weight = 80,
   category = 55000,
   rarity = 50000,
   coefficient = 100,

   elona_type = "normal_book",

   categories = {
      "elona.book"
   },

   _ext = {
      IItemTextbook
   }
}

data:add {
   _type = "base.item",
   _id = "book_of_rachel",
   elona_id = 668,
   image = "elona.item_book",
   value = 4000,
   weight = 80,
   category = 55000,
   rarity = 50000,
   coefficient = 0,

   elona_type = "normal_book",

   tags = { "noshop" },

   categories = {
      "elona.book",
      "elona.tag_noshop"
   },

   _ext = {
      IItemBookOfRachel
   }
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}
