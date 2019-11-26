local ObjectContainer = require("api.ObjectContainer")
local pool = require("internal.pool")
local uid_tracker = require("internal.uid_tracker")

local pl = pool:new("base.item", uid_tracker:new(), 1, 1)
local oc = ObjectContainer:new("base.item")

local obj = {
   _type = "base.item",
   _id = "test",
   uid = 1,
   location = nil
}

print("To pool.")
assert(pl:take_object(obj))
assert(obj.location == pl)

print("To container.")
assert(oc:take_object(obj))
assert(obj.location == oc)

print("Remove.")
assert(oc:remove_object(obj))
assert(obj.location == nil)

print("Done.")
