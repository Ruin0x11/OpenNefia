local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Gui = require("api.Gui")
local Input = require("api.Input")

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

   param1 = 1,
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
}
