local InstancedMap = require("api.InstancedMap")
local Chara = require("api.Chara")
local test_util = require("api.test.test_util")
local Assert = require("api.test.Assert")
local data = require("internal.data")
local Feat = require("api.Feat")

data:add {
   _type = "base.feat",
   _id = "nonbashable",

   is_solid = true,
   is_opaque = false,

   on_bash = nil
}

data:add {
   _type = "base.feat",
   _id = "bashable",

   is_solid = true,
   is_opaque = false,

   on_bash = function() end
}

function test_feat_event_emitter_callbacks_restored()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)

      local feat = Feat.create("@test@.bashable", 2, 2, {}, map)
      Assert.is_truthy(feat:has_event_handler("elona_sys.on_feat_bash"))
   end

   test_util.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local feat = Feat.iter(map):nth(1)

      Assert.is_truthy(feat:has_event_handler("elona_sys.on_feat_bash"))
   end
end

function test_object_change_prototype__feat_callbacks_added()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)

      local feat = Feat.create("@test@.nonbashable", 2, 2, {}, map)
      Assert.is_falsy(feat:has_event_handler("elona_sys.on_feat_bash"))

      feat:change_prototype("@test@.bashable")
      Assert.is_truthy(feat:has_event_handler("elona_sys.on_feat_bash"))
   end

   test_util.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local feat = Feat.iter(map):nth(1)

      Assert.is_truthy(feat:has_event_handler("elona_sys.on_feat_bash"))
   end
end

function test_object_change_prototype__feat_callbacks_removed()
   do
      local map = InstancedMap:new(10, 10)
      map:clear("elona.cobble")

      local player = Chara.create("base.player", 5, 5, {}, map)
      Chara.set_player(player)
      test_util.register_map(map)

      local feat = Feat.create("@test@.bashable", 2, 2, {}, map)
      Assert.is_truthy(feat:has_event_handler("elona_sys.on_feat_bash"))

      feat:change_prototype("@test@.nonbashable")
      Assert.is_falsy(feat:has_event_handler("elona_sys.on_feat_bash"))
   end

   test_util.save_cycle()

   do
      local player = Chara.player()
      local map = player:current_map()
      local feat = Feat.iter(map):nth(1)

      Assert.is_falsy(feat:has_event_handler("elona_sys.on_feat_bash"))
   end
end

function test_object_change_prototype__feat_callbacks_preserved()
   local map = InstancedMap:new(10, 10)
   map:clear("elona.cobble")

   local player = Chara.create("base.player", 5, 5, {}, map)
   Chara.set_player(player)
   test_util.register_map(map)

   local feat = Feat.create("@test@.bashable", 2, 2, {}, map)
   feat:connect_self("elona_sys.on_feat_bash", "Unrelated event", function() end)
   Assert.is_truthy(feat:has_event_handler("elona_sys.on_feat_bash"))

   feat:change_prototype("@test@.nonbashable")
   Assert.is_truthy(feat:has_event_handler("elona_sys.on_feat_bash"))
end
