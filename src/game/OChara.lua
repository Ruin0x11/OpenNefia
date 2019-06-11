local OChara = {}

-- WARNING
-- Characters must be weak proxies to allow for garbage
-- collection/easy serialization. The only serialized part is a tag
-- for indicating the field is a character (this tag's key must be
-- blacklisted as an extendable field) and its global UID. The UID is
-- stored in the parent map object pool for characters in the current
-- map. The actual content that differs from the prototype is held in
-- the pool as well.

local global = {
   ["base.chara"] = {
      next_uid = 2
   }
}

-- WARNING is this even what we want? The problem comes down to
-- references to objects held by mods. If we say there is no pool that
-- owns the object, it has to ensure that when it is deleted, all
-- references will be garbage collected. But putting a global pool per
-- map doesn't help much with flexibility as the objects are tied to
-- the map with that pool, with all the implications for moving
-- objects between maps and such.
--
-- It would probably be better to let the generated object itself be
-- the weak reference with an __indexed method like self:release()
-- that will invalidate all references. There would be no centralized
-- holder of objects in this case. But there still has to be some way
-- of iterating all items in the map, including those in containers,
-- etc.
--
-- In the end, can these requirements be satisfied?
--   - old_map:remove("base.item", item); new_map:add("base.item", item); assert(not Object.invalid(item))
--   - map:remove("base.item", item); assert(Object.invalid(item))
--   - for _, item in Item.iter_in_map() do ... end
--   - if Save.global.some_chara_that_may_have_died ~= nil then ... end
--
-- Maps probably need a list of things at the top layer regardless.
-- The focus is now on things like items that can be equipped/stored
-- in further layers. However, Item.iter()-like functions vould have
-- their own logic for handling this. That prevents those nested items
-- from needed to be tied to a map-global pool.
--
-- But then there also has to be a way to serialize the reference, if
-- it can show up in more than one place. With no authoritative place
-- to store objects it becomes impossible to know which reference
-- needs full serialization and which ones should become tagged UIDs.
--
-- Also, is item:release() needed after map:remove("base.item", item)?
-- Requiring it would prevent the mistake of an item being
-- automatically gc'd after a map:remove() but before a subsequent
-- map:add()
--
-- There may be a need for map:remove(item) as opposed to
-- map:delete(item) in terms of how the refcount is managed.
local _pool = {
   ["base.chara"] = {
      -- Sparse dictionary of UID->content, with holes inbetween
      content = {
         [1] = {
            data = {
               proto = "base.test_chara",
               x = 1,
               y = 1,
               name = "dood",
               -- __index points to prototype in data["base.chara"]["base.test_chara"]
               -- __newindex is the same as usual
               -- weak refs will __index this table's contents
            },

            -- Is this needed? for quickly removing uid from the uids array
            array_index = 1,
         }
      },

      -- Sequential array of all used uids to allow consistent iteration
      -- ...but we could just use pairs()? Order is not consistent however.
      uids = { 1 }
   }
}

local pool = class("pool")

function pool:init(type_id)
   self.type_id = type_id
   self.content = {}
   self.uids = {}
end

function pool:generate()
   local uid = global[type_id].next_uid
   global[type_id].next_uid = global[type_id].next_uid + 1

   table.insert(self.uids, uid)
   table.insert(self.content, { data = {}, array_index = #uids })
end

function pool:remove(uid)
   if self.content[uid] == nil then
      -- error("UID not found " .. uid)
      return
   end

   -- HACK terribly inefficient for over 100 elements.
   table.remove(self.uids, self.content[uid].array_index)

   self.content[uid] = nil
end

local function transfer_between(id, uid, pool_from, pool_to)
   assert(pool_from[id].content[uid] ~= nil)
   assert(pool_to[id].content[uid] == nil)
   local ind = pool_from[id].content[uid].array_index
   assert(ind ~= nil)
   assert(ind <= #pool_from[id].uids)
   assert(pool_from[id].uids[ind] == uid)

   table.remove(pool_from[id].uids, pool_from[id].content[uid].array_index)
   table.insert(pool_to[id].uids, uid)

   pool_from[id].content[uid] = pool_to[id].content[uid]
   pool_from[id].content[uid] = nil
end

return OChara
