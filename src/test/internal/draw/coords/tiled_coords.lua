local tiled_coords = require("internal.draw.coords.tiled_coords")
local Assert = require("api.test.Assert")

function test_tiled_coords_find_bounds()
   local coords = tiled_coords:new()

   local tx, ty, tdx, tdy = coords:find_bounds(0, 0, 800, 600)
   Assert.eq(-1, tx)
   Assert.eq(-1, ty)
   Assert.eq(18, tdx)
   Assert.eq(14, tdy)

   tx, ty, tdx, tdy = coords:find_bounds(48, 48 * 2, 400, 300)
   Assert.eq(-1, tx)
   Assert.eq(-1, ty)
   Assert.eq(10, tdx)
   Assert.eq(8, tdy)

   tx, ty, tdx, tdy = coords:find_bounds(-200, -400, 400, 300)
   Assert.eq(3, tx)
   Assert.eq(7, ty)
   Assert.eq(14, tdx)
   Assert.eq(16, tdy)
end
