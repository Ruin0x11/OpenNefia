local IAspect = require("api.IAspect")
local SandBagDrawable = require("mod.elona.api.gui.SandBagDrawable")
local Item = require("api.Item")

local ICharaSandBag = class.interface("ICharaSandBag", {
                                         is_hung_on_sand_bag = "boolean",
                                         sand_bag = { type = "table", optional = true }
                                                       }, { IAspect })

ICharaSandBag.default_impl = "mod.elona.api.aspect.CharaSandBagAspect"

function ICharaSandBag:hang_on_sand_bag(chara, sand_bag, remove)
   self.is_hung_on_sand_bag = true
   local chip_id, color
   if sand_bag then
      chip_id = sand_bag:calc("image")
      color = sand_bag:calc("color")
   end
   chara:set_drawable("elona.sand_bag", SandBagDrawable:new(chip_id, color), "below")
   chara:refresh()
   if sand_bag and remove then
      local sep = sand_bag:separate(1)
      sep:remove_ownership()
      self.sand_bag = sep
   end
end

function ICharaSandBag:release_from_sand_bag(chara, place_in_map)
   self.is_hung_on_sand_bag = false
   chara:set_drawable("elona.sand_bag", nil)
   chara:refresh()
   if place_in_map then
      if self.sand_bag == nil then
         Item.create("elona.sand_bag", chara.x, chara.y, nil, chara:current_map())
      else
         local map = chara:current_map()
         if map then
            map:take_object(self.sand_bag, chara.x, chara.y)
         end
      end
      self.sand_bag = nil
   end
end

return ICharaSandBag
