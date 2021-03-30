local atlas = require("internal.draw.atlas")
local tiled_coords = require("internal.draw.coords.tiled_coords")
local Assert = require("api.test.Assert")

function test_atlas_make_anim()
   local coords = tiled_coords:new()

   local tile_atlas = atlas:new(48, 48)
   local tiles = {{
         _id = "shadow",
         image = "graphic/interface.bmp"
   }}
   tile_atlas:load(tiles, coords)

   local anim = tile_atlas:make_anim("shadow")

   Assert.is_truthy(anim)
   Assert.eq(1, #anim.anims.default.frames)
end

function test_atlas_make_anim__animated()
   local coords = tiled_coords:new()

   local tile_atlas = atlas:new(48, 48)
   local tiles = {{
         _id = "tile",
         image = {
            source = "graphic/map0.bmp",
            x = 0,
            y = 0,
            width = 48,
            height = 48,
            count_x = 2
         }
   }}
   tile_atlas:load(tiles, coords)

   local anim = tile_atlas:make_anim("tile")

   Assert.is_truthy(anim)
   Assert.eq(2, #anim.anims.default.frames)
end
