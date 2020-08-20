local object = require("internal.object")

local Event = require("api.Event")
local Object = require("api.Object")
local Log = require("api.Log")

local MapObject = {}

function MapObject.generate_from(_type, id, uid_tracker)
   uid_tracker = uid_tracker or require("internal.global.save").base.uids

   local uid = uid_tracker:get_next_and_increment()

   -- params.no_pre_build = true
   local obj = Object.generate_from(_type, id)

   rawset(obj, "uid", uid)

   -- class.assert_is_an(IMapObject, data)

   return obj
end

function MapObject.generate(proto, uid_tracker)
   uid_tracker = uid_tracker or require("internal.global.save").base.uids

   local uid = uid_tracker:get_next_and_increment()

   -- params.no_pre_build = true
   local obj = Object.generate(proto)

   rawset(obj, "uid", uid)

   -- class.assert_is_an(IMapObject, obj)

   return obj
end

function MapObject.finalize(obj, params)
   return Object.finalize(obj, params)
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
function MapObject.clone_base(obj, owned)
   owned = owned or false

   -- TODO: the nomenclature is confusing. things like
   -- data["mytype"]["id"] are named 'prototypes', but there are also
   -- tables with a backing data prototype set that are also called
   -- 'prototypes'.
   local proto = Object.make_prototype(obj)
   assert(proto.location == nil)

   -- Generate a new object using the stripped object as a prototype.
   local new_object = MapObject.generate(proto)
   MapObject.finalize(new_object, { no_build=true })

   if owned and class.is_an("api.IMapObject", obj) and class.is_an("api.ILocation", obj.location) then
      -- HACK: This makes cloning characters harder, since the
      -- location also has to be changed manually, or there will be
      -- more than one character on the same square. Perhaps
      -- IMapObject:find_free_pos(x, y) would help.
      local x = new_object.x or 0
      local y = new_object.y or 0

      if not obj.location:can_take_object(new_object, x, y) then
         Log.warn("Tried to clone object %d (%s), but the location %s couldn't take the object.",
                  obj.uid, obj._type, tostring(obj.location))
         new_object:remove_ownership()
         return nil
      end

      assert(obj.location:take_object(new_object, x, y))
   end

   Event.trigger("base.on_object_cloned", {object=obj, type="base"})

   return new_object
end

function MapObject.clone(obj, owned, uid_tracker)
   uid_tracker = uid_tracker or require("internal.global.save").base.uids

   local new_object = {}

   local ignored_fields = table.set {
      "uid",
      "location"
   }

   for k, v in pairs(obj) do
      if not ignored_fields[k] then
         if type(v) == "table" then
            new_object[k] = table.deepcopy(v)
         else
            new_object[k] = v
         end
      end
   end

   new_object.uid = uid_tracker:get_next_and_increment()

   local mt = getmetatable(obj)
   setmetatable(new_object, mt)

   if owned and class.is_an("api.IMapObject", obj) and class.is_an("api.ILocation", obj.location) then
      -- HACK: This makes cloning characters harder, since the
      -- location also has to be changed manually, or there will be
      -- more than one character on the same square. Perhaps
      -- IMapObject:find_free_pos(x, y) would help.
      local x = new_object.x or 0
      local y = new_object.y or 0

      if not obj.location:can_take_object(new_object, x, y) then
         Log.warn("Tried to clone object %d (%s), but the location %s couldn't take the object.",
                  obj.uid, obj._type, tostring(obj.location))
         new_object:remove_ownership()
         return nil
      end

      assert(obj.location:take_object(new_object, x, y))
   end

   Event.trigger("base.on_object_cloned", {object=obj, type="full"})

   return new_object
end

return MapObject
