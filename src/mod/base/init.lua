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

data:add {
   _type = "base.config_option_boolean",
   _id = "exchange_crawl_up_and_buried",
}

data:add_multi(
   "base.faction",
   {
      {
         _id = "friendly",
         reactions = {
            ["base.citizen"] = 100,
            ["base.neutral"] = 50,
            ["base.enemy"] =  -100,
         }
      },
      {
         _id = "citizen",
         reactions = {
            ["base.friendly"] = 100,
            ["base.neutral"] = 50,
            ["base.enemy"] =  -100,
         }
      },
      {
         _id = "neutral",
         reactions = {
            ["base.friendly"] = 50,
            ["base.citizen"] = 50,
            ["base.enemy"] =  -100,
         }
      },
      {
         _id = "enemy",
         reactions = {
            ["base.friendly"] = -100,
            ["base.citizen"] = -100,
            ["base.neutral"] = -100,
         }
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
require("mod.base.resolver")
