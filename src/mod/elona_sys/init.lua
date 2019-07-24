local function add_elona_id(_type)
   data:extend_type(
      _type,
      {
         elona_id = schema.Number,
      }
   )
   data:add_index(_type, "elona_id")
end

data:extend_type(
   "base.chara",
   {
      impress = schema.Number,
      attract = schema.Number,
      on_gold_amount = schema.Function,
   }
)

data:extend_type(
   "base.item",
   {
      elona_id = schema.Number,
   }
)

data:extend_type(
   "base.skill",
   {
      elona_id = schema.Number,
   }
)

data:extend_type(
   "base.trait",
   {
      elona_id = schema.Number,
   }
)

data:extend_type(
   "base.scenario",
   {
      restrictions = schema.Table,
   }
)

data:extend_type(
   "base.feat",
   {
      elona_id = schema.Optional(schema.Number),
   }
)

add_elona_id("base.chara")
add_elona_id("base.item")
add_elona_id("base.skill")
add_elona_id("base.element")
add_elona_id("base.feat")
add_elona_id("base.element")

data:add_type{
   name = "effect",
   schema = {
      indicator = schema.Function,
   }
}

data["elona_sys.effect"]:edit("register status effect indicator",
   function(dat)
      local f = dat.indicator
      if f == nil then
         f = { text = dat._id }
      end
      if type(f) == "table" and type(f.text) == "string" then
         -- Create a basic indicator that appears if the effect turns
         -- are above zero.
         local indicator = f
         f = function(player)
            if player:has_effect(dat._id) then
               return indicator
            end

            return nil
         end
      end
      if type(f) == "function" then
        data:add {
           _type = "base.ui_indicator",
           _id = "effect_" .. string.split(dat._id, ".")[2],

           indicator = f
        }
        end
      return dat
                             end)

require("mod.elona_sys.data.event")

require("mod.elona_sys.theme.init")
require("mod.elona_sys.map_loader.init")
require("mod.elona_sys.map_template.init")
require("mod.elona_sys.dialog.init")

require("mod.elona_sys.events")

local Event = require("api.Event")

local function register_interface(iface, name)
   Event.register("base.on_pre_build", name .. " methods",
                  function(source)
                     if source and source._type == "base.chara" then
                        for k, v in pairs(iface) do
                           source[k] = v
                        end
                        if iface.init then
                           iface.init(source)
                        end
                     end
                  end)
end

local ICharaEffects = require("mod.elona_sys.api.chara.ICharaEffects")
register_interface(ICharaEffects, "ICharaEffects")
