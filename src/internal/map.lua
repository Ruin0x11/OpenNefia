local pool = require("internal.pool")

local map = {}

local OMap = class("OMap")

local this_map = nil

function OMap:init(width, height, uids)
   self.width = width
   self.height = height

   self.pools = {}
   self.tiles = table.of({}, width * height)
   self.uids = uids
end

function OMap:set_tile(id, x, y)
   local data = require("internal.data")
   local tile = data["base.map_tile"][id]
   if not tile then error("no tile " .. id) end
   self.tiles[y*self.width+x+1] = tile
end

function OMap:get_tile(x, y)
   return self.tiles[y*self.width+x+1]
end

function OMap:get_pool(type_id)
   self.pools[type_id] = self.pools[type_id] or pool:new(type_id, self.uids)
   return self.pools[type_id]
end

function OMap:create_object(proto, x, y)
   local _type = proto._type
   if not _type then error("no type") end

   local pool = self:get_pool(_type)
   local obj = pool:generate(proto)

   return self:add_object(obj, x, y)
end

function OMap:get_batch(type_id)
   self.batches[type_id] = self.batches[type_id] or sparse_batch:new(type_id)
   return self.batches[type_id]
end

function OMap:add_object(obj, x, y)
   local pool = self:get_pool(obj._type)
   pool:add_object(obj, obj.uid)

   obj.x = x
   obj.y = y

   return obj
end

function OMap:move_object(obj, x, y)
   assert(self:has(obj._type, obj.uid))

   obj.x = x
   obj.y = y
end

function OMap:iter_charas()
   return self:iter_objects("base.chara")
end

function OMap:iter_objects(type_id)
   return self:get_pool(type_id):iter()
end

function OMap:has(type_id, uid)
   return self:get_pool(type_id):has(uid)
end

function map.get()
   return this_map
end

function map.create()
   local uids = require("internal.global.uids")
   this_map = OMap:new(40, 40, uids)

   for y=0,40-1 do
      for x=0,40-1 do
         if x == 0 or y == 0 or x == 40-1 or y == 40-1 then
            this_map:set_tile("base.wall", x, y)
         else
            this_map:set_tile("base.floor", x, y)
         end
      end
   end

   return this_map
end

return map
