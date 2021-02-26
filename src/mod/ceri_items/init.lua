require("mod.ceri_items.data.chip")
require("mod.ceri_items.data.theme")

local Event = require("api.Event")
local ItemMemory = require("mod.elona_sys.api.ItemMemory")
local Item = require("api.Item")
local Chara = require("api.Chara")
local Theme = require("api.Theme")
local FFHP = require("mod.ceri_items.api.FFHP")
local elona_Item = require("mod.elona.api.Item")

local function iter_all_items()
   -- TODO chain everything in other character inventories
   return fun.chain(Item.iter(), Chara.player():iter_items())
end

local function apply_mapping(mapping, item)
   if mapping.chip_on_identify then
      item.image = mapping.chip_on_identify
   end
   if mapping.color_on_identify then
      item.color = table.deepcopy(mapping.color_on_identify)
   end
end

local function set_item_image_on_memorize(_, params)
   if not Theme.is_active("ceri_items.ceri_items") then
      return
   end

   if params.is_known then
      local mapping = FFHP.mapping_for(params._id)
      if mapping then
         for _, item in iter_all_items():filter(function(i) return i._id == params._id end) do
            apply_mapping(mapping, item)
         end
      end
   else
      for _, item in iter_all_items():filter(function(i) return i._id == params._id end) do
         item.image = item.proto.image
         item.color = elona_Item.default_item_color(item)
      end
   end
end

Event.register("elona_sys.on_item_memorize_known", "Set item image to FFHP override", set_item_image_on_memorize)

local function set_item_image_on_generate(obj, params)
   if obj._type ~= "base.item" then
      return
   end

   if (ItemMemory.is_known(obj._id) or params.is_shop) and Theme.is_active("ceri_items.ceri_items") then
      local mapping = FFHP.mapping_for(obj._id)
      if mapping then
         apply_mapping(mapping, obj)
      end
   end
end

Event.register("base.on_generate", "Set item image to FFHP override", set_item_image_on_generate)

local function set_item_images(map)
   for _, item in Item.iter_in_everything(map) do
      item.image = item.proto.image
      item.color = elona_Item.default_item_color(item)
      if ItemMemory.is_known(item._id) and Theme.is_active("ceri_items.ceri_items") then
         local mapping = FFHP.mapping_for(item._id)
         if mapping then
            apply_mapping(mapping, item)
         end
      end
   end
end

Event.register("base.on_map_enter", "Set item image to FFHP override", set_item_images)
Event.register("base.on_theme_switched", "Set item image to FFHP override",
               function()
                  local player = Chara.player()
                  if Chara.is_alive(player) then
                     set_item_images(player:current_map())
                  end
end)

Event.register("base.on_hotload_end", "Clear FFHP mapping cache", function(_, params)
                  if params.hotloaded_types["ceri_items.ffhp_mapping"] then
                     FFHP.clear_cache()
                  end
end)
