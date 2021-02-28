local Event = require("api.Event")
local Rand = require("api.Rand")

data:add_type {
   name = "god",
   schema = schema.Record {
      elona_id = schema.Number
   }
}

data:add_index("elona.god", "elona_id")

local function set_god(chara)
   local has_dialog = true

   if not chara:is_player() and has_dialog then
      local gods = data["elona.god"]:iter():extract("_id"):to_list()
      gods[#gods+1] = "eyth"
      chara.god = Rand.choice(gods)
      if chara.god == "eyth" then
         chara.god = nil
      end
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
