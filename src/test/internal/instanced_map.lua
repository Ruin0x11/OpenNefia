local uid_tracker = require("internal.uid_tracker")
local draw = require("internal.draw")
local instanced_map = require("internal.instanced_map")

local tiles = {
   floor = {
      image = 451,
      is_solid = false
   },
   wall = {
      image = 300,
      is_solid = true
   }
}

local charas = {
   player = {
      _id = "base.player",
      _type = "base.chara",

      image = 4,
   },
}

test("map - is in bounds", function()
        local u = uid_tracker:new()
        local m = instanced_map:new(20, 20, u, tiles)

        ok(m:is_in_bounds(10, 10))

        m:set_tile(10, 10, tiles["wall"])

        ok(m:is_in_bounds(10, 10))
        ok(m:is_in_bounds(0, 0))
        ok(m:is_in_bounds(19, 19))

        ok(not m:is_in_bounds(20, 19))
        ok(not m:is_in_bounds(-1, 0))
        ok(not m:is_in_bounds(0, -1))
        ok(not m:is_in_bounds(19, 20))
end)

test("map - can access", function()
        local u = uid_tracker:new()
        local m = instanced_map:new(20, 20, u, tiles)

        ok(m:can_access(10, 10))

        m:set_tile(10, 10, tiles["wall"])

        ok(not m:can_access(10, 10))
end)

local function shadows_match(shadows, s)
   local i = 0
   local j = 0
   for l in string.lines(s) do
      i = 0
      for c in string.chars(l) do
         local s = shadows[i][j]
         local is_shadow = bit.band(s, 0x100) == 0x100
         if is_shadow and c ~= "#" then
            return false
         elseif not is_shadow and c == "#" then
            return false
         end
         i = i + 1
      end
      j = j + 1
   end

   return true
end

local function print_shadows(shadows)
   print("==============")
   for i=0, #shadows do
      for j=0,#shadows do
         local o = shadows[j][i] or 0
         local i = "."
         if bit.band(o, 0x100) > 0 then
            i = "#"
         end
         io.write(i)
      end
      io.write("\n")
   end
end

local function assert_shadows_match(m, x, y, f, s)
   local shadows = m:calc_screen_sight(x, y, f)
   ok(shadows_match(shadows, s))
end

test("map - calc screen sight", function()
        local u = uid_tracker:new()
        local m = instanced_map:new(10, 10, u, tiles)

        m:set_tile(5, 5, tiles["wall"])

        local coords = require("internal.draw.coords.tiled_coords"):new()
        draw.set_coords(coords)

        assert_shadows_match(
           m, 3, 5, 8,
              [[
..............
.##########...
.##########...
.#.....####...
........###...
........###...
.......####...
........###...
........###...
.#.....####...
.##########...
..............
..............
..............
]]
        )
end)

test("map - chara lifecycle", function()
        local u = uid_tracker:new()
        local m = instanced_map:new(20, 20, u, tiles)

        local c = m:create_object(charas["player"], 5, 5)

        ok(m:exists(c))

        m:remove_object(c)

        ok(not m:exists(c))

        m:add_object(c, 5, 5)

        ok(m:exists(c))
end)

test("map - chara position", function()
        local u = uid_tracker:new()
        local m = instanced_map:new(20, 20, u, tiles)

        local c = m:create_object(charas["player"], 5, 5)

        ok(m:exists(c))
        ok(c.x == 5)
        ok(c.y == 5)

        m:move_object(c, 1, 1)
        ok(c.x == 1)
        ok(c.y == 1)
end)

test("map - positional query", function()
        local u = uid_tracker:new()
        local m = instanced_map:new(20, 20, u, tiles)

        local c = m:create_object(charas["player"], 5, 5)

        ok(table.deepcompare(m:objects_at("base.chara", 5, 5), { c.uid }))
        ok(table.deepcompare(m:objects_at("base.chara", 5, 4), {}))

        m:move_object(c, 5, 4)

        ok(table.deepcompare(m:objects_at("base.chara", 5, 5), {}))
        ok(table.deepcompare(m:objects_at("base.chara", 5, 4), { c.uid }))

        m:remove_object(c, 5, 4)

        ok(table.deepcompare(m:objects_at("base.chara", 5, 5), {}))
        ok(table.deepcompare(m:objects_at("base.chara", 5, 4), {}))
end)
