local EquipSlots = require("api.EquipSlots")
local Item = require("api.Item")
local Chara = require("api.Chara")
local InstancedMap = require("api.InstancedMap")

test("EquipSlots - free slot", function()
        local map = InstancedMap:new(20, 20)
        local bp = {
           "test.hand"
        }
        local eq = EquipSlots:new(bp)
        local i = Item.create("test.sword", 0, 0, {}, map)

        ok(t.are_same(1, eq:find_free_slot(i)))
end)

test("EquipSlots - take and remove", function()
        local map = InstancedMap:new(20, 20)
        local bp = {
           "test.hand"
        }
        local eq = EquipSlots:new(bp)
        local i = Item.create("test.sword", 0, 0, {}, map)

        ok(not eq:has_object(i))

        ok(eq:take_object(i))
        ok(eq:has_object(i))

        ok(map:take_object(i, 5, 6))
        ok(not eq:has_object(i))
        ok(i.x == 5)
        ok(i.y == 6)
end)

test("EquipSlots - no free slots", function()
        local map = InstancedMap:new(20, 20)
        local bp = {
           "test.hand",
           "test.hand"
        }
        local eq = EquipSlots:new(bp)

        local a = Item.create("test.sword", 0, 0, {}, map)
        local b = Item.create("test.sword", 0, 1, {}, map)
        local c = Item.create("test.sword", 0, 2, {}, map)

        ok(eq:equip(a))
        ok(eq:equip(b))
        ok(not eq:equip(c))

        ok(not eq:equip(a))

        ok(eq:unequip(a))
        ok(eq:equip(c))
end)

test("EquipSlots - wrong slot type", function()
        local map = InstancedMap:new(20, 20)
        local bp = {
           "test.hand",
        }
        local eq = EquipSlots:new(bp)

        local i = Item.create("test.sword", 0, 0, {}, map)

        i:mod("equip_slots", { "test.chest" })

        ok(not eq:equip(i))

        i:refresh()

        ok(eq:equip(i))
end)

test("EquipSlots - items for type", function()
        local map = InstancedMap:new(20, 20)
        local bp = {
           "test.hand",
           "test.hand",
           "test.chest"
        }
        local eq = EquipSlots:new(bp)

        local a = Item.create("test.sword", 0, 0, {}, map)
        local b = Item.create("test.sword", 0, 1, {}, map)
        local c = Item.create("test.armor", 0, 2, {}, map)

        ok(eq:equip(a))
        ok(eq:equip(b))
        ok(eq:equip(c))

        local items = eq:items_for_type("test.hand")

        ok(t.are_same(items[1].uid, a.uid))
        ok(t.are_same(items[2].uid, b.uid))

        items = eq:items_for_type("test.chest")

        ok(t.are_same(items[1].uid, c.uid))
end)
