local object = require("internal.object")

local Object = require("api.Object")
local Log = require("api.Log")

local MapObject = {}

function MapObject.generate_from(_type, id, params, uid_tracker)
   params = params or {}
   uid_tracker = uid_tracker or require("internal.global.save").base.uids

   local uid = uid_tracker:get_next_and_increment()

   local obj = Object.generate_from(_type, id, {no_pre_build=true})

   rawset(obj, "uid", uid)

   -- class.assert_is_an(IMapObject, data)

   if not params.no_pre_build then
      obj:pre_build()

      if not params.no_build then
         obj:normal_build()
         obj:finalize()
      end
   end

   return obj
end

function MapObject.generate(proto, params, uid_tracker)
   params = params or {}
   uid_tracker = uid_tracker or require("internal.global.save").base.uids

   local uid = uid_tracker:get_next_and_increment()

   local obj = Object.generate(proto, {no_pre_build=true})

   rawset(obj, "uid", uid)

   -- class.assert_is_an(IMapObject, obj)

   if params.copy then
      for k, v in pairs(params.copy) do
         obj[k] = v
      end
   end

   if not params.no_pre_build then
      obj:pre_build()

      if not params.no_build then
         obj:normal_build()
         obj:finalize()
      end
   end

   return obj
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
function MapObject.clone(obj, owned)
   owned = owned or false

   -- TODO: the nomenclature is confusing. things like
   -- data["mytype"]["id"] are named 'prototypes', but there are also
   -- tables with a backing data prototype set that are also called
   -- 'prototypes'.
   local proto = Object.make_prototype(obj)
   assert(proto.location == nil)

   -- Generate a new object using the stripped object as a prototype.
   local new_object = MapObject.generate(proto, {no_pre_build=true})

   -- TODO: move
   local IMapObject = require("api.IMapObject")
   if owned and class.is_an(IMapObject, obj) then
      -- HACK: This makes cloning characters harder, since the
      -- location also has to be changed manually, or there will be
      -- more than one character on the same square. Perhaps
      -- IMapObject:find_free_pos(x, y) would help.
      local x = new_object.x or 0
      local y = new_object.y or 0

      if not obj.location.can_take_object(new_object, x, y) then
         Log.warn("Tried to clone object %d (%s), but the location %s couldn't take the object.",
                  obj.uid, obj._type, tostring(obj.location))
         new_object:remove_ownership()
         return nil
      end

      assert(obj.location:take_object(new_object, x, y))
   end

   return new_object
end

return MapObject
