--
-- Remains
--
local Enum = require("api.Enum")
local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")
local IItemMuseumValued = require("mod.elona.api.aspect.IItemMuseumValued")
local ItemMuseumValuedFigureAspect = require("mod.elona.api.aspect.ItemMuseumValuedFigureAspect")
local ItemMuseumValuedCardAspect = require("mod.elona.api.aspect.ItemMuseumValuedCardAspect")
local FigurineDrawable = require("mod.elona.api.gui.FigurineDrawable")
local CardDrawable = require("mod.elona.api.gui.CardDrawable")

data:add {
   _type = "base.item",
   _id = "remains_skin",
   elona_id = 337,
   image = "elona.item_rabbits_tail",
   value = 100,
   weight = 1500,
   coefficient = 100,
   categories = {
      "elona.remains"
   },
   _ext = {
      IItemFromChara
   }
}

data:add {
   _type = "base.item",
   _id = "remains_blood",
   elona_id = 338,
   image = "elona.item_remains_blood",
   value = 100,
   weight = 1500,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.remains"
   },
   _ext = {
      IItemFromChara
   }
}

data:add {
   _type = "base.item",
   _id = "remains_eye",
   elona_id = 339,
   image = "elona.item_remains_eye",
   value = 100,
   weight = 1500,
   rarity = 400000,
   coefficient = 100,
   categories = {
      "elona.remains"
   },
   _ext = {
      IItemFromChara
   }
}

data:add {
   _type = "base.item",
   _id = "remains_heart",
   elona_id = 340,
   image = "elona.item_remains_heart",
   value = 100,
   weight = 1500,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.remains"
   },
   _ext = {
      IItemFromChara
   }
}

data:add {
   _type = "base.item",
   _id = "remains_bone",
   elona_id = 341,
   image = "elona.item_remains_bone",
   value = 100,
   weight = 1500,
   coefficient = 100,
   categories = {
      "elona.remains"
   },
   _ext = {
      IItemFromChara
   }
}

--
-- Card/Figure
--

data:add {
   _type = "base.item",
   _id = "figurine",
   elona_id = 503,
   image = "elona.item_figurine",
   value = 1000,
   weight = 2500,
   fltselect = Enum.FltSelect.Sp,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.remains",
      "elona.no_generate"
   },
   _ext = {
      IItemFromChara,
      [IItemMuseumValued] = {
         _impl = ItemMuseumValuedFigureAspect
      }
   },
   events = {
      {
         id = "base.on_item_init_params",
         name = "Set figurine drawable",

         callback = function(self, params)
            local aspect = self:get_aspect_or_default(IItemFromChara)

            if aspect.image then
               local chip = data["base.chip"]:ensure(aspect.image)
               if chip.is_tall then
                  self.image = "elona.item_figurine_tall"
               end
            end

            self:set_drawable("elona.figurine", FigurineDrawable:new(aspect.image, aspect.color), "above", 10000)

            self:refresh_cell_on_map()
         end
      }
   }
}

data:add {
   _type = "base.item",
   _id = "card",
   elona_id = 504,
   image = "elona.item_card",
   value = 500,
   weight = 200,
   fltselect = Enum.FltSelect.Sp,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.remains",
      "elona.no_generate"
   },
   _ext = {
      IItemFromChara,
      [IItemMuseumValued] = {
         _impl = ItemMuseumValuedCardAspect
      }
   },
   events = {
      {
         id = "base.on_item_init_params",
         name = "Set card drawable",

         callback = function(self, params)
            local aspect = self:get_aspect_or_default(IItemFromChara)

            self:set_drawable("elona.figurine", CardDrawable:new(aspect.image, aspect.color), "above", 10000)

            self:refresh_cell_on_map()
         end
      }
   }
}

--[[
      local chara_color = chara.color

      local function set_collectable_params(tag, drawable_klass)
         return function(item)
            item:set_aspect(IItemFromChara, Aspect.new_default(IItemFromChara, item, { chara = chara }))

            -- special case for card/figure. the color of the chara chip displayed
            -- is changed, not the figure/card itself. (so not item.color)
            local chara_color = table.deepcopy(chara_color)

            -- TODO api to get the default image for a character (including class)
            -- :calc("image") probably shouldn't be used here
            local chara_image = chara.proto.image or chara:calc("image") or nil

            if item._id == "elona.figurine" and chara_image then
               local chip = data["base.chip"]:ensure(chara_image)
               if chip.is_tall then
                  item.image = "elona.item_figurine_tall"
               end
            end

            -- TODO preinit item.params before on_init_params, so this can get
            -- moved into the on_init_params() callback
            item:set_drawable(tag, drawable_klass:new(chara_image, chara_color), "above", 10000)

            item:refresh_cell_on_map()
         end
      end
--]]
