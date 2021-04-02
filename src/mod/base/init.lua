data:add_multi(
   "base.talk_event",
   {
      {
         _id = "ai_aggro"
      },
      {
         _id = "ai_calm"
      },
      {
         _id = "ai_melee"
      },
      {
         _id = "ai_ranged"
      }
   }
)

local Fs = require("api.Fs")

local function load_with_root(base, add, opts)
   local copy = table.deepcopy(add)
   if copy.file then
      copy.file = Fs.join(opts.root, copy.file)
   else
      copy.file = base.file
   end
   return copy
end

local chip_loader = {
   _type = "base.asset_loader",
   _id = "base_chip",

   target = "base.chip",

   on_load = load_with_root
}

local map_chip_loader = {
   _type = "base.asset_loader",
   _id = "base_map_chip",

   target = "base.map_chip",

   on_load = load_with_root
}

local sound_loader = {
   _type = "base.asset_loader",
   _id = "base_sound",

   target = "base.sound",

   on_load = load_with_root
}

local music_loader = {
   _type = "base.asset_loader",
   _id = "base_music",

   target = "base.music",

   on_load = load_with_root
}

require("mod.base.sound")

data["base.effect"]:edit("register status effect indicator",
   function(dat)
      if type(dat.indicator) == "string" then
        data:add {
           _type = "base.ui_indicator",
           _id = "effect_" .. string.split(dat._id, ".")[2],
            -- Create a basic indicator that appears if the effect turns
            -- are above zero.
            indicator = function(player)
               if player:has_effect(dat._id) then
                  local raw = { text = dat.indicator }
                  raw.color = dat.color or nil
                  return raw
               end

               return nil
            end
        }
      elseif type(dat.indicator) == "function" then
        data:add {
           _type = "base.ui_indicator",
           _id = "effect_" .. string.split(dat._id, ".")[2],

           indicator = function(chara)
              if chara:has_effect(dat._id) then
                 local raw = dat.indicator(chara)
                 raw.color = dat.color or nil
                 return raw
              end
           end,
           ordering = dat.ordering
        }
        end
      return dat
end)

require("mod.base.data")
