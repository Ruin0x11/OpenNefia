local Map = require("api.Map")
local Event = require("api.Event")
local Item = require("api.Item")
local Chara = require("api.Chara")
local ItemEx = require("mod.ffhp.api.ItemEx")

local function set_item_image_on_memorize(_, params)
   local map = Map.current()

   if map then
      Item.iter_in_everything(map)
         :filter(function(i) return i._id == params._id end)
         :each(ItemEx.refresh_item_appearance)
   end
end

Event.register("elona_sys.on_item_memorize_known", "Set item image to FFHP override", set_item_image_on_memorize)

local function set_item_image_on_generate(obj, params)
   if obj._type ~= "base.item" then
      return
   end

   ItemEx.refresh_item_appearance(obj)
end

Event.register("base.on_item_generate", "Set item image to FFHP override", set_item_image_on_generate)

local function set_item_images(map)
   Item.iter_in_everything(map):each(ItemEx.refresh_item_appearance)
end

Event.register("base.on_map_changed", "Set item image to FFHP override", set_item_images)
Event.register("base.on_theme_switched", "Set item image to FFHP override",
               function()
                  ItemEx.clear_cache()
                  local map = Map.current()
                  if map then
                     set_item_images(map)
                  end
end)

Event.register("base.on_hotload_end", "Clear FFHP mapping cache", function(_, params)
                  if params.hotloaded_types["ffhp.item_ex_mapping"] then
                     ItemEx.clear_cache()
                     local map = Map.current()
                     if map then
                        set_item_images(map)
                     end
                  end
end)
