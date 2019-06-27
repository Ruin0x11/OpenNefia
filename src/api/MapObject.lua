local Object = require("api.Object")
local Log = require("api.Log")
local uids = require("internal.global.uids")

local MapObject = {}

function MapObject.generate_from(_type, id, uid_tracker)
   local data = require("internal.data")
   local proto = data[_type]:ensure(id)
   return MapObject.generate(proto, uid_tracker)
end

local function makeindex(proto)
   return function(t, k)
      local v = rawget(t, k)
      if v ~= nil then
         return v
      end

      return proto[k]
   end
end

function MapObject.generate(proto, uid_tracker)
   uid_tracker = uid_tracker or uids

   local uid = uid_tracker:get_next_and_increment()

   -- if the passed object was a previously instantiated one, take its
   -- proto field and merge the rest of the fields after building
   -- TODO: prefix proto as __proto since it serves a special purpose
   local used_proto = proto
   local merge_rest = false

   -- HACK: there needs to be a better way of telling "is/was this a
   -- map object instance?"
   local is_instance = used_proto.uid ~= nil

   if is_instance then
      assert(used_proto.location == nil)

      local data = require("internal.data")
      used_proto = data[used_proto._type][used_proto._id]
      merge_rest = true

      -- remove fields that shouldn't be merged into the new instance
      proto.proto = nil
      proto.uid = nil
   end

   local tbl = {
      temp = {},
      proto = used_proto
   }

   local data = setmetatable(tbl, { __index = makeindex(proto) })

   rawset(data, "uid", uid)
   data.x = 0
   data.y = 0

   data:build()
   data:refresh()

   if merge_rest then
      data = table.merge(data, proto)
   end

   return data
end

--- Copies all non-class fields in an object to a new object, giving
--- it a new UID. If `owned` is true, also attempts to transfer the
--- object to the original object's location. If this fails, deletes
--- the cloned object and returns nil. If unsuccessful, no state is
--- changed except the UID increment.
-- @tparam IMapObject object
-- @tparam bool owned
-- @treturn[1] IMapObject
-- @treturn[2] nil
function MapObject.clone(object, owned)
   owned = owned or false

   -- TODO: the nomenclature is confusing. things like
   -- data["mytype"]["id"] are named 'prototypes', but there are also
   -- tables with a backing data prototype set that are also called
   -- 'prototypes'.
   local proto = Object.make_prototype(object)
   assert(proto.location == nil)

   -- Generate a new object using the stripped object as a prototype.
   local new_object = MapObject.generate(proto)

   if owned and is_an(IObject, object) then
      -- HACK: This makes cloning characters harder, since the
      -- location also has to be changed manually, or there will be
      -- more than one character on the same square. Perhaps
      -- IMapObject:find_free_pos(x, y) would help.
      local x = new_object.x or 0
      local y = new_object.y or 0

      if not object.location.can_take_object(new_object, x, y) then
         Log.warn("Tried to clone object %d (%s), but the location %s couldn't take the object.",
                  object.uid, object._type, tostring(object.location))
         new_object:remove_ownership()
         return nil
      end

      assert(object.location:take_object(new_object, x, y))
   end

   return new_object
end

return MapObject
