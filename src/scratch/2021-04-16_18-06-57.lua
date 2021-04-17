local Enum = require("api.Enum")
local Skill = require("mod.elona_sys.api.Skill")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Item = require("api.Item")
local Magic = require("mod.elona_sys.api.Magic")

data:add {
   _id = "artifact",
   _type = "base.item",
   custom_author = "円環の女神",
   damage_bonus = 10,
   dice_x = 5,
   dice_y = 10,
   dv = 2,
   effective_range = { 50, 90, 100, 100, 90, 70, 70, 60, 60, 50 },
   hit_bonus = 10,
   identify_difficulty = 500,
   level = 800,
   material = "elona.rubynus",
   on_use = function(self, params)
      return true
   end,
   pierce_rate = 20,
   pv = 2,
   quality = Enum.Quality.Unique,
   rarity = 1000000,
   skill = "elona.bow",
   value = 5000,
   weight = 1500
}

data:add {
   _id = "artifact",
   _type = "base.item",
   custom_author = "円環の女神",

   identify_difficulty = 500,
   level = 800,
   material = "elona.rubynus",
   quality = Enum.Quality.Unique,
   rarity = 1000000,
   value = 5000,
   weight = 1500,

   ext = {
      ["base.equipment"] = {
         damage_bonus = 10,
         dice_x = 5,
         dice_y = 10,
         dv = 2,
         hit_bonus = 10,
         pierce_rate = 20,
         pv = 2,
         skill = "elona.bow",
      },
      ["base.ranged_weapon"] = {
         effective_range = { 50, 90, 100, 100, 90, 70, 70, 60, 60, 50 },
      },
      ["base.useable"] = {
         on_use = function(self, params)
            return true
         end
      }
   },
}

data:add {
   _type = "base.item",
   _id = "thick_gauntlets",

   elona_id = 10,
   image = "elona.item_thick_gauntlets",
   value = 400,
   weight = 1100,
   material = "elona.metal",
   coefficient = 100,
   categories = {
      "elona.equip_wrist_gauntlet",
      "elona.equip_wrist"
   },

   ext = {
      ["base.equipment"] = {
         hit_bonus = 2,
         damage_bonus = 1,
         pv = 4,
         dv = 2,
         equip_slots = { "elona.arm" },
      }
   }
}

local IScrollAspect = class.interface("IScrollAspect",
                                      { effects = "table", },
                                      { IAItemReadable })

local ScrollAspect = class.class("ScrollAspect", IScrollAspect)

function ScrollAspect:init(item, params)
   self.effects = params.effects or {}
end

function ScrollAspect:on_read(item, params)
   return Magic.read_scroll(params.chara, self.effects)
end

local ConfirmableScrollAspect = class.class("ConfirmableScrollAspect", IScrollAspect)

ConfirmableScrollAspect:delegate("inner", IScrollAspect)

function ConfirmableScrollAspect:init(item, params)
   self.inner = ScrollAspect:new(item, params)
end

function ConfirmableScrollAspect:on_read(item, params)
   if not Input.yes_no() then
      return "player_turn_query"
   end
   return self.inner:on_read(item, params)
end

data:add {
   _type = "base.item",
   _id = "scroll_of_incognito",

   elona_id = 17,
   image = "elona.item_scroll",
   value = 3500,
   weight = 20,
   rarity = 70000,
   coefficient = 0,

   categories = {
      "elona.scroll",
   },

   -- on_read = function(self, params)
   --    return ElonaMagic.read_scroll(self, {{ _id = "elona.buff_incognito", power = 300 }}, params)
   -- end,

   ext = {
      ["elona.unknown_item"] = {
         knownnameref = "scroll",
         originalnameref2 = "scroll",
         has_random_name = true,
         random_color = "Random",
      },
      [IScrollAspect] = {
         effects = {
            { _id = "elona.buff_incognito", power = 300 }
         }
      }
   }
}

data:add {
   _type = "base.item",
   _id = "lemon",

   elona_id = 197,
   image = "elona.item_magic_fruit",
   value = 240,
   weight = 440,
   material = "elona.fresh",
   category = 57000,
   subcategory = 57004,
   coefficient = 100,

   categories = {
      "elona.food_fruit",
      "elona.food"
   },

   ext = {
      ["base.food"] = {
         food_type = "elona.fruit",
         spoilage_hours = 12
      }
   }
}

data:add {
   _type = "base.extension",
   _id = "food",

   applies_to = "base.item",

   on_build = function(self, params)
      local p = get_param(params, IAItemFood)
      local aspect = self:get_aspect_or_default(IAItemFood, p)
   end
}

local ITextbookAspect = class.interface("ITextbookAspect",
                                        { skill_id = "string", },
                                        { IAItemReadable })

data:add {
   _type = "base.ext",
   _id = "textbook",

   aspect = ITextbookAspect
}

local TextbookAspect = class.class("TextbookAspect", ITextbookAspect)

function TextbookAspect:init(item, params)
   -- >>>>>>>> shade2/item.hsp:619 	if iId(ci)=idBookSkill	:if iBookId(ci)=0:iBookId( ..
   self.skill_id = params.skill_id or Skill.random_skill()
   -- <<<<<<<< shade2/item.hsp:619 	if iId(ci)=idBookSkill	:if iBookId(ci)=0:iBookId( ..
end

function TextbookAspect:on_read(item, params)
   local skill_id = self.skill_id
   local chara = params.chara
   if chara:is_player() and not chara:has_skill(skill_id) then
      Gui.mes("action.read.book.not_interested")
      if not Input.yes_no() then
         return "player_turn_query"
      end
   end

   chara:start_activity("elona.training", {skill_id=skill_id,item=item})

   return "turn_end"
end

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

   ext = {
      ITextbookAspect
   },

   categories = {
      "elona.book"
   }
}

local textbook = Item.create("elona.textbook", nil, nil, { ownerless = true, params = { [ITextbookAspect] = { skill_id = "elona.evasion" } } })
local aspect = textbook:get_aspect_or_default(ITextbookAspect)
print(aspect.skill_id)
