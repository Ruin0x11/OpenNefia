local areas = {
   areas = {},
   maps = {}
}

local UID = 0

function areas:create_area(id, x, y)
   UID = UID + 1
   local uid = UID
   self.areas[uid] = {
      uid = uid,
      id = id,
      x = x,
      y = y,
      maps = {}
   }
   return uid
end

function areas:remove_area(area_uid)
   local area = self.areas[area_uid]
   if area == nil then
      error(("Area %s does not exist"):format(area_uid))
   end

   for _, map_uid in ipairs(area.maps) do
      self.maps[map_uid] = nil
   end

   self.areas[area_uid] = nil
end

function areas:add_map(area_uid, map_uid)
   local area = self.areas[area_uid]
   if area == nil then
      error(("Area %s does not exist"):format(area_uid))
   end
   if self.maps[map_uid] ~= nil then
      error(("Map UID %d is already part of an area: %d"):format(map_uid, self.maps[map_uid]))
   end

   area.maps[map_uid] = {}
   self.maps[map_uid] = area_uid
end

function areas:remove_map(map_uid)
   local area = self:area_for_map(map_uid)
   if area == nil then
      return
   end

   area.maps[map_uid] = nil
   self.maps[map_uid] = nil
end

function areas:area(area_uid)
   return self.areas[area_uid]
end

function areas:area_for_map(map_uid)
   local area_uid = self.maps[map_uid]
   if area_uid == nil then
      return nil
   end

   return self.areas[area_uid]
end

function areas:world_map_position(map_uid)
   local area = self:area_for_map(map_uid)
   if area == nil then
      return nil, nil
   end

   return area.x, area.y
end

_ppr("test")

local area_uid = areas:create_area("test", 10, 20)
areas:add_map(area_uid, 1)
areas:add_map(area_uid, 2)
areas:add_map(area_uid, 3)
areas:add_map(area_uid, 4)

_ppr(areas:world_map_position(3))
areas:remove_map(3)
_ppr(areas:world_map_position(3))
areas:add_map(area_uid, 3)
_ppr(areas:world_map_position(3))
areas:remove_area(area_uid)
_ppr(areas:world_map_position(3))



local Draw = require("api.Draw")
local Gui = require("api.Gui")

local anim = function(draw_x, draw_y)
   local item_atlas = require("internal.global.atlases").get().item
   local chip = item_atlas:copy_tile_image("elona.item_statue_ornamented_with_plants#1")

   local r = 0
   for i = 0, 100 do
      for x = 1, 20 do
         for y = 1, 10 do
            Draw.set_color(0, 0, 0, 80)
            --love.graphics.setBlendMode("")
            local ox = 24
            local oy = 96
            love.graphics.draw(chip.image, x * 96, y * 96, math.rad(10), nil, nil, ox, oy, 0, 0)
            love.graphics.setBlendMode("alpha")
            Draw.set_color(255, 255, 255)
            love.graphics.draw(chip.image, x * 96, y * 96, nil, nil, nil, ox, oy)
         end
      end
      r = r + 1
      Draw.yield()
   end

end
Gui.start_draw_callback(anim)

