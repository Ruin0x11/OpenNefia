local object = require("internal.object")

local Object = require("api.Object")
local Log = require("api.Log")
local uids = require("internal.global.uids")

local MapObject = {}

function MapObject.generate_from(_type, id, params, uid_tracker)
   params = params or {}
   uid_tracker = uid_tracker or uids

   local uid = uid_tracker:get_next_and_increment()

   local data = {}
   object.deserialize(data, _type, id)

   rawset(data, "uid", uid)

   -- class.assert_is_an(IMapObject, data)

   data:pre_build()

   if not params.no_build then
      data:normal_build()
      data:build()
   end

   return data
end

function MapObject.generate(proto, params, uid_tracker)
   error("broken")
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
   error("broken")
   owned = owned or false

   -- TODO: the nomenclature is confusing. things like
   -- data["mytype"]["id"] are named 'prototypes', but there are also
   -- tables with a backing data prototype set that are also called
   -- 'prototypes'.
   local proto = Object.make_prototype(object)
   assert(proto.location == nil)

   -- Generate a new object using the stripped object as a prototype.
   local new_object = MapObject.generate(proto)

   local IMapObject = require("api.IMapObject")
   if owned and class.is_an(IMapObject, object) then
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
