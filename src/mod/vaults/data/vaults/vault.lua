data:add_type {
   name = "vault"
}

require("mod.vaults.data.vaults.test2")
require("mod.vaults.data.vaults.arrival")
require("mod.vaults.data.vaults.lines")
require("mod.vaults.data.vaults.float")


--[[
-- tags:
--
--   allow_dup: Vault can be used more than once per nefia (spanning all of its
--              floors)? Needs to take into consideration branching paths.
--   entry: Entry vault.
--   generate_awake: Monsters generated awake
--   no_item_gen: No items generated, except the ones specified
--   no_rotate
--   no_hmirror
--   no_vmirror

-- In Crawl, minivaults are vaults that are placed after the level has been
-- generated.

data:add {
   _type = "vault",
   _id = "test1",

   orient = "float",

   -- Places the vault can appear in. Supports nefia type, danger level, and
   -- area floor numbers. Omitting this prevents random generation of the vault.
   appears_in = {
      { type = "level", min = 7, max = 20 },
      { type = "floor", min = 7, max = 20 },
      { type = "floor", invert = true, min = 7, max = 20 },
      { nefia = "elona.fort" },
      { type = "floor", nefia = "elona.fort", invert = true, min = 7, max = 20 },
   },

   chance = {
      5.01,
      { type = "floor", nefia = "elona.fort", min = 7, max = 20, chance = 50.0 },
   },

   -- When picked from vault_group or similar, weight used for random weighted
   -- sampler
   weight = {
      10,
      { nefia = "elona.fort", weight = 50 },
   }
}

data:add {
   _type = "vault_group",
   _id = "test",

   vaults = {
      "vaults.test1",
      "vaults.test1",
   },

   chance = 5.01
}
--]]
