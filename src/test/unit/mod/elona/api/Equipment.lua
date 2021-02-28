local Chara = require("api.Chara")
local Equipment = require("mod.elona.api.Equipment")
local Assert = require("api.test.Assert")
local InstancedMap = require("api.InstancedMap")

function test_Equipment_generate_initial_equipment_spec()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local lomias = Chara.create("elona.lomias", nil, nil, {}, map)

   local equip_spec = Equipment.generate_initial_equipment_spec(lomias)

   local ids = table.set {
      "elona.long_sword",
      "elona.bow_of_vindale",
   }

   for _, spec in pairs(equip_spec) do
      if spec._id and ids[spec._id] then
         ids[spec._id] = nil
      end
   end

   Assert.eq(0, table.count(ids), "Not all unique equipment was specified to be generated")
end

function test_Equipment_generate_initial_equipment()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local lomias = Chara.create("elona.lomias", nil, nil, {}, map)

   local ids = table.set {
      "elona.long_sword",
      "elona.bow_of_vindale",
   }

   for _, equip in lomias:iter_equipment() do
      if ids[equip._id] then
         ids[equip._id] = nil
      end
   end

   Assert.eq(0, table.count(ids), "Not all unique equipment was generated")
end
