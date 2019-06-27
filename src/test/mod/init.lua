local dangerous = {
   "load",
   "loadfile",
   "dofile",
   "package",
   "jit",
   "os"
}

for _, name in ipairs(dangerous) do
   local success, exists = pcall(function() return _G[name] ~= nil end)
   assert(not success)
   assert(exists ~= true)
end

data:add {
   _type = "base.chara",
   _id = "chara",

   body_parts = {
      "test.hand",
      "test.hand",
      "test.chest",
   }
}

data:add {
   _type = "base.body_part",
   _id = "hand",
}

data:add {
   _type = "base.body_part",
   _id = "chest",
}

data:add {
   _type = "base.item",
   _id = "sword",

   equip_slots = {
      "test.hand"
   }
}

data:add {
   _type = "base.item",
   _id = "armor",

   equip_slots = {
      "test.chest"
   }
}

data:add {
   _type = "base.map_tile",
   _id = "floor",

   image = "graphic/temp/map_tile/1_207.png",
   is_solid = false,
   is_opaque = false
}

data:add {
   _type = "base.map_tile",
   _id = "wall",

   image = "graphic/temp/map_tile/1_399.png",
   is_solid = true,
   is_opaque = true
}
