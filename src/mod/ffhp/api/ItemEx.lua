local Compat = require("mod.elona_sys.api.Compat")
local Fs = require("api.Fs")
local Csv = require("mod.extlibs.api.Csv")
local Theme = require("api.Theme")
local ElonaItem = require("mod.elona.api.ElonaItem")
local ItemMemory = require("mod.elona_sys.api.ItemMemory")
local CodeGenerator = require("api.CodeGenerator")
local Log = require("api.Log")
local Chara = require("api.Chara")
local ItemExChipVariantPrompt = require("mod.ffhp.api.gui.ItemExChipVariantPrompt")

local ItemEx = {}

local cache

local function gen_cache()
   cache = {}

   for _, mapping in data["ffhp.item_ex_mapping"]:iter() do
      local override = Theme.get_override("ffhp.item_ex_mapping", mapping._id)
      if override ~= nil
         and override.chip_id ~= nil
         and override.color ~= nil
      then
         cache[override.item_id] = override
      end
   end
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
   if mapping.chip_id then
      -- Don't apply the mapped image if the item's current image is different
      -- than the prototype's image. For items like raw noodles, the image can
      -- get changed dynamically based on things like cooked dish quality. If we
      -- did not do this, then an override for the raw noodle image would also
      -- get applied to cooked noodle dishes.
      if item.proto.image == nil or item.image == item.proto.image then
         item.image = mapping.chip_id
      end
   else
      item.image = ElonaItem.default_item_image(item)
   end
   if mapping.color then
      item.color = table.deepcopy(mapping.color)
   else
      item.color = ElonaItem.default_item_color(item)
   end
end

function ItemEx.can_apply_mapping(item, mapping)
   return ItemMemory.is_known(item._id)
end

function ItemEx.refresh_item_appearance(item)
   -- TODO need a way to update an item's memory in the map

   local mapping = ItemEx.mapping_for(item._id)
   if mapping and ItemEx.can_apply_mapping(item, mapping) then
      ItemEx.apply_mapping(mapping, item)
   end
end

function ItemEx.query_change_chip_variant(item, chips)
   if chips == nil then
      local mapping = ItemEx.mapping_for(item._id)
      if mapping == nil then
         chips = {}
      else
         chips = {mapping.chip_id}
         local variants = mapping.chip_variants
         if type(variants) == "table" and #variants > 0 then
            table.append(chips, variants)
         end
      end
   end

   local chip
   if #chips == 0 then
      return nil
   elseif #chips == 1 then
      chip = chips[1]
   else
      local player = Chara.player()
      if not Chara.is_alive(player) then
         return nil
      end

      local result, canceled = ItemExChipVariantPrompt:new(player.x, player.y, chips):query()
      if result and not canceled and result.chip then
         chip = result.chip
      else
         chip = chips[1]
      end
   end

   -- XXX: Would be better to store this in an aspect, so it gets preserved
   -- better between theme changes.
   item.image = chip

   return chip
end

function ItemEx.parse_item_ex_csv(csv_file, base_path, mod_id)
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
      local chip_path = Fs.join(base_path, "graphic", "item", ("itemEx_%03d.bmp"):format(chip_id))
      local height = tonumber(row[3])
      local y_offset = tonumber(row[4])
      local stack_height = tonumber(row[5])
      local shadow = tonumber(row[6])
      local color = tonumber(row[7])
      local use_directional_chips = tonumber(row[8])
      if use_directional_chips == 1 then
         use_directional_chips = true
         chip_path = Fs.join(base_path, "graphic", "item", ("itemEx2_%03d.bmp"):format(chip_id))
      end

      if color then
         color = assert(Compat.convert_122_color_index(color))
      end

      local chip_variants = {}
      if not use_directional_chips then
         for i = 1, 16 do
            local path = Fs.join(base_path, "graphic", "item", ("itemEx_%03d-%d.bmp"):format(chip_id, i))
            if Fs.exists(path) then
               chip_variants[#chip_variants+1] = { chip_path = path, index = i }
            end
         end
      end

      if not Fs.exists(chip_path) then
         if #chip_variants > 0 then
            chip_path = table.remove(chip_variants, 1).chip_path
         else
            Log.warn("Missing FFHP item image %s", chip_path)
            return nil
         end
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
         use_directional_chips = use_directional_chips,
         chip_variants = chip_variants
      }
   end

   return Csv.parse_file(csv_file, {shift_jis=true}):map(map):filter(fun.op.truth):to_list()
end

function ItemEx.convert_item_ex_csv(csv_file, base_path, mod_id)
   local raw = ItemEx.parse_item_ex_csv(csv_file, base_path, mod_id)

   local lookup = data["ffhp.item_ex_mapping"]:iter()
   :map(function(m) data["base.item"]:ensure(m.item_id); return m.item_id, m end)
      :to_map()

   local gen = CodeGenerator:new()

   gen:write("local chips = ")
   gen:write_table_start()
   gen:tabify()
   for _, entry in ipairs(raw) do
      local mapping = assert(lookup[entry.item_id], entry.item_id .. ", " .. entry.chip_id)

      assert(not entry.use_directional_chips)

      local function add_chip(chip_path, id)
         local _id = mapping._id:gsub("^[^.]+%.", "") .. id
         gen:write_table_start()
         do
            gen:write_key_value("_id", _id)
            gen:write_key_value("image", chip_path)
            if entry.stack_height then
               gen:write_key_value("stack_height", entry.stack_height)
            end
            if entry.shadow then
               gen:write_key_value("shadow", entry.shadow)
            end
            if entry.y_offset then
               gen:write_key_value("y_offset", entry.y_offset)
            end
            if entry.shadow then
               gen:write_key_value("shadow", entry.shadow)
            end
            if entry.height == 96 then
               gen:write_key_value("is_tall", true)
            end
         end
         gen:write_table_end()
         gen:write(",")
         gen:tabify()
         return mod_id .. "." .. _id
      end

      add_chip(entry.chip_path, "")

      if #entry.chip_variants > 0 then
         entry.chip_variant_ids = {}
         for i, c in ipairs(entry.chip_variants) do
            local _id = add_chip(c.chip_path, "_" .. c.index)
            table.insert(entry.chip_variant_ids, _id)
         end
      end
   end
   gen:write_table_end()
   gen:tabify()

   gen:tabify()
   gen:write("data:add_multi(\"base.chip\", chips)")
   gen:tabify()
   gen:tabify()

   local mappings = fun.iter(raw)
      :map(function(entry)
            local mapping = assert(lookup[entry.item_id], entry.item_id)
            local override = {
               -- TODO ffhp data_ext
               chip_id = mod_id .. "." .. entry.item_id:gsub("%.", "_"),
               color = entry.color or nil,
               chip_variants = entry.chip_variant_ids or nil
            }
            return mapping._id, override
          end)
      :to_map()

   local overrides = {
      ["ffhp.item_ex_mapping"] = mappings
   }

   gen:write("data:add ")
   gen:write_table {
      _type = "base.theme",
      _id = mod_id,

      overrides = overrides
   }
   gen:tabify()

   return tostring(gen)
end

return ItemEx
