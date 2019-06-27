local uid_tracker = require("internal.uid_tracker")
local draw = require("internal.draw")
local MapObject = require("api.MapObject")
local InstancedMap = require("api.InstancedMap")

test("map - is in bounds", function()
        local u = uid_tracker:new()
        local m = InstancedMap:new(20, 20, u, "test.floor")

        ok(m:is_in_bounds(10, 10))

        m:set_tile(10, 10, "test.wall")

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
        local m = InstancedMap:new(20, 20, u, "test.floor")

        ok(m:can_access(10, 10))

        m:set_tile(10, 10, "test.wall")

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
   local s = ""
   for i=0, #shadows do
      for j=0,#shadows do
         local o = shadows[j][i] or 0
         local i = "."
         if bit.band(o, 0x100) > 0 then
            i = "#"
         end
         s = s .. i
      end
      s = s .. "\n"
   end
   return s
end

local function assert_shadows_match(m, x, y, f, s)
   local shadows = m:calc_screen_sight(x, y, f)
   ok(shadows_match(shadows, s), print_shadows(shadows) .. "\n=====\n" .. s)
end

test("map - calc screen sight", function()
        local u = uid_tracker:new()
        local m = InstancedMap:new(10, 10, u, "test.floor")

        m:set_tile(5, 5, "test.wall")

        local coords = require("internal.draw.coords.tiled_coords"):new()
        draw.set_coords(coords)

        assert_shadows_match(
           m, 3, 5, 8,
              [[
..............
..............
..##########..
..##########..
..#.....####..
.........###..
.........###..
........####..
.........###..
.........###..
..#.....####..
..##########..
..............
..............
]]
        )
end)

test("map - chara lifecycle", function()
        local u = uid_tracker:new()
        local m = InstancedMap:new(20, 20, u, "test.floor")

        local o = MapObject.generate_from("base.chara", "test.chara")
        local c = m:take_object(o, 5, 5)

        ok(m:has_object(c))

        ok(m:remove_object(c))

        ok(not m:has_object(c))

        ok(m:take_object(c, 5, 5))

        ok(m:has_object(c))
end)

test("map - chara position", function()
        local u = uid_tracker:new()
        local m = InstancedMap:new(20, 20, u, "test.floor")

        local o = MapObject.generate_from("base.chara", "test.chara")
        local c = m:take_object(o, 5, 5)

        ok(m:has_object(c))
        ok(c.x == 5)
        ok(c.y == 5)

        ok(m:move_object(c, 1, 1))
        ok(m:has_object(c))
        ok(c.x == 1)
        ok(c.y == 1)
end)

test("map - positional query", function()
        local u = uid_tracker:new()
        local m = InstancedMap:new(20, 20, u, "test.floor")

        local o = MapObject.generate_from("base.chara", "test.chara")
        local c = m:take_object(o, 5, 5)

        ok(t.are_same(m:iter_type_at_pos("base.chara", 5, 5):to_list(), { c }))
        ok(t.are_same(m:iter_type_at_pos("base.chara", 5, 4):to_list(), {}))

        ok(m:move_object(c, 5, 4))

        ok(t.are_same(m:iter_type_at_pos("base.chara", 5, 5):to_list(), {}))
        ok(t.are_same(m:iter_type_at_pos("base.chara", 5, 4):to_list(), { c }))

        ok(m:remove_object(c, 5, 4))

        ok(t.are_same(m:iter_type_at_pos("base.chara", 5, 5):to_list(), {}))
        ok(t.are_same(m:iter_type_at_pos("base.chara", 5, 4):to_list(), {}))
end)

test("map - gc", function()
        local u = uid_tracker:new()
        local m = InstancedMap:new(20, 20, u, "test.floor")
        local o = MapObject.generate_from("base.chara", "test.chara")
        local c = m:take_object(o, 5, 5)

        local t = setmetatable({c}, { __mode = "v" })

        ok(m:remove_object(c))
        o = nil
        c = nil
        collectgarbage()

        ok(t[1] == nil)
end)
