local Compat = {}
local Enum = require("api.Enum")

function Compat.convert_122_id(_type, elona_id)
   local it = data[_type]:find_by("elona_id", elona_id)
   if it then
      return it._id
   end

   return nil, ("Cannot find entry of type '%s' with elona_id '%s'"):format(_type, elona_id)
end

local function gen_chip_convert(group)
   return function(elona_id)
      local pred = function(c) return c.group == group and c.elona_id == elona_id end
      local it = data["base.chip"]:iter():filter(pred):nth(1)
      if it then
         return it._id
      end

      return nil
   end
end

Compat.convert_122_chara_chip = gen_chip_convert("chara")
Compat.convert_122_item_chip = gen_chip_convert("item")
Compat.convert_122_feat_chip = gen_chip_convert("feat")

function Compat.convert_122_map_chip(elona_atlas, elona_id)
   assert(elona_atlas, "need atlas number")
   assert(elona_id, "need ID")
   local pred = function(c) return c.elona_atlas == elona_atlas and c.elona_id == elona_id end
   local it = data["base.map_tile"]:iter():filter(pred):nth(1)
   if it then
      return it._id
   end

   return nil
end

function Compat.convert_122_item_category(category)
   assert(category)
   return data["base.item_type"]:iter():filter(function(i) return i.ordering == category end):extract("_id"):nth(1)
end

local COLORS = {
   [0] = "White",
   [1] = "White",
   [2] = "Green",
   [3] = "Red",
   [4] = "Blue",
   [5] = "Yellow",
   [6] = "Brown",
   [7] = "Black",
   [8] = "Purple",
   [9] = "SkyBlue",
   [10] = "Pink",
   [11] = "Orange",
   [12] = "White",
   [13] = "Fresh",
   [14] = "DarkGreen",
   [15] = "Gray",
   [16] = "LightRed",
   [17] = "LightBlue",
   [18] = "LightPurple",
   [19] = "LightGreen",
   [20] = "Talk",
   -- [21] = "RandomFurniture",
   -- [22] = "RandomSeeded",
   -- [23] = "RandomAny"
}

function Compat.convert_122_color_index(color_idx)
   local color = COLORS[color_idx]
   assert(color, "Unknown color " .. color_idx)
   return Enum.Color[color]
end

function Compat.convert_122_talk_event(elona_txt_id)
   local filter = function(te)
      if te.elona_txt_id == elona_txt_id then
         return true
      end

      if te.variant_txt_ids then
         for _, id in pairs(te.variant_txt_ids) do
            if id == elona_txt_id then
               return true
            end
         end
      end

      return false
   end
   return data["base.talk_event"]:iter():filter(filter):extract("_id"):nth(1)
end

return Compat
