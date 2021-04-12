local Enum = require("api.Enum")
local VaultTilemap = require("mod.vaults.api.VaultTilemap")
local Feat = require("api.Feat")
local Item = require("api.Item")
local Area = require("api.Area")
local InstancedMap = require("api.InstancedMap")
local Log = require("api.Log")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")

local VaultBuilder = class.class("VaultBuilder")

VaultBuilder.Orient = Enum.new("Orient", {
   Minivault = "minivault",
   Float = "float",
   Encompass = "encompass",
   North = "north",
   Northwest = "northwest",
   West = "west",
   Southwest = "southwest",
   South = "south",
   Southeast = "southeast",
   East = "east",
   Northeast = "northeast",
})

function VaultBuilder:init(tilemap)
   self._tags = table.set {}
   self._orient = VaultBuilder.Orient.Minivault

   self.width, self.height, self.tiles = VaultTilemap.extract_params(tilemap)

   self._tileset = "vaults.default"
   self.tilemap = {
      ["."] = "vaults.builder_floor",
      ["x"] = "vaults.builder_rock_wall",
      ["c"] = "vaults.builder_stone_wall",
      ["v"] = "vaults.builder_metal_wall",
      ["b"] = "vaults.builder_crystal_wall",
   }
   self.callbacks = {
      ["+"] = function(map, x, y)
         Feat.create("elona.door", x, y, {}, map)
      end,
      ["T"] = function(map, x, y)
         Item.create("elona.fountain", x, y, {}, map)
      end,
      ["}"] = function(map, x, y, area, floor)
         assert(Area.create_stairs_down(area, floor+1, x, y, {}, map))
      end,
      ["{"] = function(map, x, y, area, floor)
         if floor == 1 then
            local parent_area = Area.parent(area)
            local _, _, floor = parent_area:child_area_position(area)
            assert(Area.create_stairs_up(parent_area, floor, x, y, {}, map))
         else
            assert(Area.create_stairs_up(area, floor-1, x, y, {}, map))
         end
      end,
   }
end

function VaultBuilder:tags(tag)
   self._tags[tag] = true
end

function VaultBuilder:orient(orient)
   assert(VaultBuilder.Orient:has_value(orient))
   self._orient = orient
end

function VaultBuilder:tileset(tileset)
   data["elona_sys.map_tileset"]:ensure(tileset)
   self._tileset = tileset
end

function VaultBuilder:shuffle(shuffle)
   local shuffles = VaultTilemap.make_shuffle(shuffle)

   local do_shuffle = function(shuffle)
      local mapping = {}
      for idx, tile in ipairs(self.tiles) do
         local to = shuffle[tile]
         if to then
            mapping[idx] = to
         end
      end
      for idx, to in pairs(mapping) do
         self.tiles[idx] = to
      end
   end

   fun.iter(shuffles):each(do_shuffle)
end

function VaultBuilder:build(area, floor)
   class.assert_is_an("api.InstancedArea", area)
   assert(math.type(floor) == "integer")
   local map = InstancedMap:new(self.width, self.height)
   map.tileset = self._tileset

   local exits = {}

   for idx, tile in ipairs(self.tiles) do
      local x = (idx-1) % self.width
      local y = math.floor((idx-1) / self.width)

      local map_tile, callback

      if tile == "@" then
         map_tile = "vaults.builder_floor"
         callback = nil
         exits[#exits+1] = { x = x, y = y }
      else
         map_tile = self.tilemap[tile]
         callback = self.callbacks[tile]
      end

      if map_tile == nil then
         if callback == nil then
            Log.warn("Missing tile '%s' in vault tilemap", tile)
         end
         map_tile = "vaults.builder_floor"
      end
      map:set_tile(x, y, map_tile)

      if callback then
         callback(map, x, y, area, floor)
      end
   end

   return map, exits
end

function VaultBuilder.test()
   local test = require("mod.vaults.data.vaults.test")

   local builder = VaultBuilder:new(test.map)
   test.main(builder)
   local map, exits = builder:build(Area.current(), 20)

   local parent = InstancedMap:new(50, 50)
   parent:clear("vaults.builder_rock_wall")
   parent.tileset = map.tileset

   parent:splice(map, 25 - map:width() / 2, 25 - map:height() / 2)

   MapTileset.apply(parent.tileset, parent)

   return parent
end

return VaultBuilder
