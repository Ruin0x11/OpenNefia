local MapTileset = {}

local function convert_fog(tileset, map)
   local fog = tileset.fog
   local id

   for _, x, y, tile in map:iter_tiles() do
      if type(fog) == "string" then
         id = fog
      elseif type(fog) == "function" then
         id = fog(x, y, tile)
      end

      map:reveal_tile(x, y, id)
   end

   map.default_tile = id
end

local function convert_tiles(tileset, map)
   local default = data["elona_sys.map_tileset"]["elona.default"]

   for _, x, y, tile in map:iter_tiles() do
      local match = tileset.tiles[tile._id]

      -- quirk in the original map generation algorithm: there are two
      -- mapgen tile IDs for the map floor, but one is used for hidden
      -- paths and another is used for walls. This is so when digging
      -- tunnels the map generator doesn't accidentally dig into a
      -- tile holding a hidden path, but still lets it appear like the
      -- default tile.
      if match == nil and tile._id == "elona.mapgen_default" then
         match = tileset.tiles["elona.mapgen_floor"]
         if match == nil then
            match = default.tiles["elona.mapgen_floor"]
         end
      end

      if match == nil then
         match = default.tiles[tile._id]
      end

      if match then
         local id
         if type(match) == "string" then
            id = match
         elseif type(match) == "function" then
            id = match(x, y, tile)
         end

         map:set_tile(x, y, id)
      end
   end
end

local function convert_doors(tileset, map)
   if tileset.door.open_tile then
      data["base.chip"]:ensure(tileset.door.open_tile)
   end
   if tileset.door.closed_tile then
      data["base.chip"]:ensure(tileset.door.closed_tile)
   end

   local doors = map:iter_feats()
   :filter(function(f) return f._id == "elona.door" end)

   for _, door in doors:unwrap() do
      if tileset.door.open_tile then
         door.open_tile = tileset.door.open_tile
      end
      if tileset.door.closed_tile then
         door.closed_tile = tileset.door.closed_tile
      end
   end
end

function MapTileset.apply(tileset_id, map)
   local tileset = data["elona_sys.map_tileset"]:ensure(tileset_id)

   if tileset.fog then
      convert_fog(tileset, map)
   end

   if tileset.tiles then
      convert_tiles(tileset, map)
   end

   if tileset.door then
      convert_doors(tileset, map)
   end
end

function MapTileset.get(tile_id, map)
   local tileset = data["elona_sys.map_tileset"]:ensure(map.tileset)
   local match = tileset.tiles[tile_id]

   local id

   if match then
      if type(match) == "string" then
         id = match
      elseif type(match) == "function" then
         id = match()
      end
   end

   return id
end

function MapTileset.get_default_tile(map)
   local tileset = data["elona_sys.map_tileset"]:ensure(map.tileset or "elona.default")
   return tileset.fog
end

return MapTileset
