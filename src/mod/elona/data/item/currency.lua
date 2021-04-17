local Gui = require("api.Gui")
local Enum = require("api.Enum")
local Rand = require("api.Rand")
local Map = require("api.Map")
local Event = require("api.Event")

-- >>>>>>>> shade2/calculation.hsp:854 #defcfunc calcInitGold int c ..
local function calc_initial_gold(_, params, result)
   local item = params.item
   local owner = params.owner
   local map = params.map or Map.current()

   if not owner then
      local base = (map and map.level or 1) * 25
      local is_shelter = false -- TODO shelter
      if is_shelter then
         base = 1
      end

      return Rand.rnd(base + 10) + 1
   end

   local calc = owner.proto.calc_initial_gold
   if calc then
      return calc(owner)
   end

   return item.amount
end
-- <<<<<<<< shade2/calculation.hsp:863 	return rnd(cLevel(c)*25+10)+1 ...

local hook_calc_initial_gold =
   Event.define_hook("calc_initial_gold",
                     "Initial gold amount.",
                     1,
                     nil,
                     calc_initial_gold)

data:add {
   _type = "base.item",
   _id = "gold_piece",
   elona_id = 54,
   image = "elona.item_gold_piece",
   value = 1,
   weight = 0,
   category = 68000,
   coefficient = 100,

   prevent_sell_in_own_shop = true,

   events = {
      {
         id = "base.on_get_item",
         name = "Add gold to inventory",
         priority = 50000,

         callback = function(self, params)
            Gui.play_sound("base.getgold1", params.chara.x, params.chara.y)
            Gui.mes("action.pick_up.execute", params.chara, self:build_name(params.amount))
            params.chara.gold = params.chara.gold + self.amount
            self:remove_ownership()
            return true
         end
      },
      {
         id = "elona.on_item_created_from_wish",
         name = "Adjust amount",

         callback = function(self, params)
            -- >>>>>>>> shade2/command.hsp:1595 		if iId(ci)=idGold:iNum(ci)=cLevel(pc)*cLevel(pc) ..
            self.amount = params.chara:calc("level") * params.chara:calc("level") * 50 + 20000
            -- <<<<<<<< shade2/command.hsp:1595 		if iId(ci)=idGold:iNum(ci)=cLevel(pc)*cLevel(pc) ..
         end
      },
   },

   on_init_params = function(self, params)
      -- >>>>>>>> shade2/item.hsp:650 	if iId(ci)=idGold{ ..
      self.amount = hook_calc_initial_gold({item=self,owner=params.owner})
      if self:calc("quality") == Enum.Quality.Good then
         self.amount = self.amount * 2
      end
      if self:calc("quality") >= Enum.Quality.Great then
         self.amount = self.amount * 4
      end

      if params.owner then
         params.owner.gold = params.owner.gold + self.amount
         self:remove_ownership()
      end
      -- <<<<<<<< shade2/item.hsp:655 		} ..
   end,

   categories = {
      "elona.gold"
   }
}

data:add {
   _type = "base.item",
   _id = "platinum_coin",
   elona_id = 55,
   image = "elona.item_platinum_coin",
   value = 1,
   weight = 1,
   category = 69000,
   coefficient = 100,
   tags = { "noshop" },
   always_drop = true,

   categories = {
      "elona.platinum",
      "elona.tag_noshop"
   },

   events = {
      {
         id = "base.on_get_item",
         name = "Add platinum to inventory",
         priority = 50000,

         callback = function(self, params)
            Gui.mes("action.pick_up.execute", params.chara, self:build_name(params.amount))
            Gui.play_sound(Rand.choice({"base.get1", "base.get2"}), params.chara.x, params.chara.y)
            params.chara.platinum = params.chara.platinum + self.amount
            self:remove_ownership()
         end
      },
      {
         id = "elona.on_item_created_from_wish",
         name = "Adjust amount",

         callback = function(self, params)
            -- >>>>>>>> shade2/command.hsp:1596 		if iId(ci)=idPlat:iNum(ci)=8+rnd(5) ..
            self.amount = 8 + Rand.rnd(5)
            -- <<<<<<<< shade2/command.hsp:1596 		if iId(ci)=idPlat:iNum(ci)=8+rnd(5) ..
         end
      },
   }
}

data:add {
   _type = "base.item",
   _id = "small_medal",
   elona_id = 622,
   image = "elona.item_small_medal",
   value = 1,
   weight = 1,
   category = 77000,
   rarity = 10000,
   coefficient = 100,

   is_precious = true,
   always_stack = true,

   tags = { "noshop" },
   rftags = { "ore" },
   categories = {
      "elona.tag_noshop",
      "elona.ore"
   }
}

data:add {
   _type = "base.item",
   _id = "music_ticket",
   elona_id = 724,
   image = "elona.item_token_of_friendship",
   value = 1,
   weight = 1,
   fltselect = 1,
   category = 77000,
   rarity = 10000,
   coefficient = 100,

   is_precious = true,

   tags = { "noshop" },
   rftags = { "ore" },
   categories = {
      "elona.tag_noshop",
      "elona.no_generate",
      "elona.ore"
   }
}

data:add {
   _type = "base.item",
   _id = "token_of_friendship",
   elona_id = 730,
   image = "elona.item_token_of_friendship",
   value = 1,
   weight = 1,
   fltselect = 1,
   category = 77000,
   rarity = 10000,
   coefficient = 100,
   originalnameref2 = "token",

   is_precious = true,

   tags = { "noshop" },
   rftags = { "ore" },
   categories = {
      "elona.tag_noshop",
      "elona.no_generate",
      "elona.ore"
   }
}
