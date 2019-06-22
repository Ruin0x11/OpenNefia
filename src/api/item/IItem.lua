local field = require("game.field")
local IMapObject = require("api.IMapObject")

-- TODO: move out of api
local IItem = interface("IItem",
                         {},
                         {
                            IMapObject,
                         })

function IItem:build()
   -- TODO remove and place in schema as defaults

   self.number = self.number or 1
   self.location = nil
   self.ownership = "none"

   self.curse_state = "cursed"
   self.identify_state = "completely"

   self.flags = {}

   self.name = self._id
   self.weight = 10

   -- item:send("base.on_item_create")
end

function IItem:build_name()
   return self.name
end

function IItem:refresh()
   self.temp = {}
end

function IItem:get_equip_slots()
   local base = self:calc("equip_slots") or {}

   return base
end

function IItem:copy_image()
   local _, _, item_atlas = require("internal.global.atlases").get()
   return item_atlas:copy_tile_image(self.image)

end

return IItem
