local Compat = require("mod.elona_sys.api.Compat")
local Fs = require("api.Fs")
local Csv = require("mod.extlibs.api.Csv")
local Theme = require("api.Theme")
local ElonaItem = require("mod.elona.api.ElonaItem")
local ItemMemory = require("mod.elona_sys.api.ItemMemory")

local ItemEx = {}

local cache

local function gen_cache()
   local map = function(mapping)
      local override = Theme.get_override("ffhp.item_ex_mapping", mapping._id)
      if override == nil then
         return nil
      end

      if override.chip_on_identify == nil
         and override.color_on_identify == nil
      then
         return nil
      end

      return mapping.item_id, override
   end
   cache = data["ffhp.item_ex_mapping"]:iter()
      :map(map)
      :filter(fun.op.truth)
      :to_map()
end

function ItemEx.clear_cache()
   cache = nil
end

function ItemEx.mapping_for(item_id)
   if cache == nil then
      gen_cache()
   end

   return cache[item_id]
end

function ItemEx.apply_mapping(mapping, item)
   if mapping.chip_on_identify then
      -- Don't apply the mapped image if the item's current image is different
      -- than the prototype's image. For items like raw noodles, the image can
      -- get changed dynamically based on things like cooked dish quality. If we
      -- did not do this, then an override for the raw noodle image would also
      -- get applied to cooked noodle dishes.
      if item.proto.image == nil or item.image == item.proto.image then
         item.image = mapping.chip_on_identify
      end
   end
   if mapping.color_on_identify then
      item.color = table.deepcopy(mapping.color_on_identify)
   else
      item.color = nil
   end
end

function ItemEx.refresh_item_appearance(item)
   item.image = ElonaItem.default_item_image(item)
   item.color = ElonaItem.default_item_color(item)
   -- TODO need a way to update an item's memory in the map

   local mapping = ItemEx.mapping_for(item._id)
   if mapping and ItemMemory.is_known(item._id) then
      ItemEx.apply_mapping(mapping, item)
   end
end

function ItemEx.parse_item_ex_csv(csv_file, base_path)
   local map = function(row)
      row[#row] = row[#row]:gsub("//.*", "")

      -- itemEx.csvの記述
      -- 第１カラム：元となるアイテムのアイテムID
      -- 第２カラム：置換するアイテムチップID
      -- ※以下省略可能
      -- 第３カラム：置換するアイテムチップIDに対する高さ指定
      -- 　　　　　　※要するにチップの高さ
      -- 第４カラム：置換するアイテムチップIDで描画する際の指定
      -- 　　　　　　※ソース中でchipIfで表記、置いた時のどのくらい浮いているか？
      -- 第５カラム：置換するアイテムチップIDで描画する際の指定
      -- 　　　　　　※ソース中でchipIsで表記、スタックさせた場合の重なり具合？
      -- 第６カラム：置換するアイテムチップIDで描画する際の指定
      -- 　　　　　　※ソース中でchipIshで表記、描画時の影に関する何か？
      -- 第７カラム：置換するアイテムチップIDで描画する際の色補正番号指定
      -- 　　　　　　※１で、補正無。多分２１位まで指定可能
      --
      -- In the omake variants, column 8 is '1' if the image is an 8-way chip.
      -- [48px * 384px / 96px * 384px]

      local item_id = assert(Compat.convert_122_id("base.item", tonumber(row[1])))
      local chip_id = assert(tonumber(row[2]))
      local chip_path = Fs.join(base_path, "graphic", "item", ("itemEx_%d.bmp"):format(chip_id))
      local height = tonumber(row[3])
      local y_offset = tonumber(row[4])
      local stack_height = tonumber(row[5])
      local shadow = tonumber(row[6])
      local color = tonumber(row[7])
      local use_directional_chips = tonumber(row[8])
      if use_directional_chips == "1" then
         use_directional_chips = true
      end

      if color then
         color = assert(Compat.convert_122_color_index(color))
      end

      return {
         item_id = item_id,
         chip_id = chip_id,
         chip_path = chip_path,
         height = height,
         y_offset = y_offset,
         stack_height = stack_height,
         shadow = shadow,
         color = color,
         use_directional_chips = use_directional_chips
      }
   end

   return Csv.parse_file(csv_file, {shift_jis=true}):map(map):to_list()
end

return ItemEx
