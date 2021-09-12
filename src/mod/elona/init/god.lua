local Event = require("api.Event")
local God = require("mod.elona.api.God")

local ty_god_item = types.fields {
   id = types.data_id("base.item"),
   no_stack = types.optional(types.boolean),
   only_once = types.optional(types.boolean),
   properties = types.optional(types.table),
}

local ty_god_offering = types.some(
   types.fields_strict {
      type = types.literal("category"),
      id = types.data_id("base.item_type"),
   },
   types.fields_strict {
      type = types.literal("item"),
      id = types.data_id("base.item"),
   }
)

data:add_type {
   name = "god",
   fields = {
      {
         name = "elona_id",
         indexed = true,
         type = types.optional(types.uint)
      },
      {
         name = "is_primary_god",
         type = types.boolean
      },
      {
         name = "summon",
         type = types.optional(types.data_id("base.chara"))
      },
      {
         name = "servant",
         type = types.data_id("base.chara")
      },
      {
         name = "items",
         type = types.list(ty_god_item)
      },
      {
         name = "artifact",
         type = types.data_id("base.item")
      },
      {
         name = "blessings",
         type = types.list(types.callback("chara", types.map_object("base.chara")))
      },
      {
         name = "offerings",
         type = types.list(ty_god_offering),
         default = {}
      },
      {
         name = "on_join_faith",
         type = types.optional(types.callback("chara", types.map_object("base.chara")))
      },
      {
         name = "on_leave_faith",
         type = types.optional(types.callback("chara", types.map_object("base.chara")))
      }
   }
}

local function set_god(chara)
   local has_dialog = chara.can_talk or chara.dialog

   if not chara:is_player() and has_dialog and chara.god == nil then
      chara.god = God.random_god_id()
   end
end

Event.register("base.on_chara_normal_build",
               "Set NPC god", set_god)

local function apply_god_blessing(chara)
   local id = chara:calc("god") or ""
   local god = data["elona.god"][id]
   if not god then
      return
   end

   for _, v in ipairs(god.blessings or {}) do
      v(chara)
   end
end

Event.register("base.on_refresh",
               "Apply god blesssing", apply_god_blessing)

-- {
--  "elona.stat_dexterity",
--  "elona.stat_perception",
--  "elona.healing",
--  "elona.firearm",
--  "elona.detection",
--  "elona.lock_picking",
--  "elona.carpentry",
--  "elona.jeweler",
--  "elona.stat_perception",
--  "elona.stat_speed",
--  "elona.bow",
--  "elona.crossbow",
--  "elona.stealth",
--  "elona.magic_device",
--  "elona.stat_magic",
--  "elona.meditation",
--  "elona.element_fire",
--  "elona.element_cold",
--  "elona.element_lightning",
--  "elona.stat_charisma",
--  "elona.stat_luck",
--  "elona.evasion",
--  "elona.magic_capacity",
--  "elona.fishing",
--  "elona.lock_picking",
--  "elona.stat_strength",
--  "elona.stat_constitution",
--  "elona.shield",
--  "elona.weight_lifting",
--  "elona.mining",
--  "elona.magic_device",
--  "elona.stat_will",
--  "elona.healing",
--  "elona.meditation",
--  "elona.anatomy",
--  "elona.cooking",
--  "elona.magic_device",
--  "elona.magic_capacity",
--  "elona.stat_perception",
--  "elona.stat_dexterity",
--  "elona.stat_learning",
--  "elona.gardening",
--  "elona.alchemy",
--  "elona.tailoring",
--  "elona.literacy"
--  }
