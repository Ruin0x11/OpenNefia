local Env = require("api.Env")

data:add_type {
   name = "item_ex_mapping",
   fields = {
      {
         name = "item_id",
         type = types.data_id("base.item"),
         template = true,
      },
      {
         name = "chip_id",
         type = types.optional(types.data_id("base.chip")),
         template = true,
      },
      {
         name = "color",
         type = types.optional(types.color),
         template = true,
      },
      {
         name = "chip_variants",
         type = types.optional(types.list(types.data_id("base.chip"))),
      }
   }
}

-- TODO move this to a data edit system so an override can be added without the
-- need for manually creating an override prototype
--
-- If someone adds a new potion type, they would have to have knowledge of the
-- ffhp system to have it be themable. A different modder cannot add a ffhp
-- override to the custom potion type by only using base.theme; they would also
-- need to add an ffhp.item_ex_mapping every time. And then more than one
-- mapping for the same item could exist, which is bad.
--
-- Maybe data_ext should be compatible with theme_transformer instead, meaning
-- this item_ex_mapping would be stored on the base.item itself in _ext
data:add {
   _type = "base.theme_transform",
   _id = "item_ex_mapping",

   applies_to = "ffhp.item_ex_mapping",
   transform = function(t, override)
      t.chip_id = override.chip_id
      t.color = override.color
      t.chip_variants = override.chip_variants
      return t
   end
}

-- XXX: stopgap for compatibility with all elona items, this should be removed
-- later!
local function make_mappings(raw, kind)
   return data["base.item"]:iter()
     :filter(Env.mod_filter("elona"))
      :map(function(i)
            return {
               _id = i._id:gsub("%.", "_"),
               item_id = i._id
            }
          end)
     :to_list()
end

data:add_multi("ffhp.item_ex_mapping", make_mappings())
