local Feat = require("api.Feat")
local Layout = require("mod.tools.api.Layout")
local Log = require("api.Log")
local Item = require("api.Item")
local I18N = require("api.I18N")

local SokobanMap = {}

local DEST_TILE = "elona.cyber_3"

function SokobanMap.is_solved(map)
   local barrels = Feat.iter(map):filter(function(f) return f._id == "sokoban.barrel" end)
   local barrel_count = barrels:length()

   if barrel_count == 0 then
      return true
   end

   local found = table.set {}
   local positions = map:iter_tiles():filter(function(x, y, tile) return tile._id == DEST_TILE end)

   if barrel_count ~= positions:length() then
      Log.warn("This map is unsolveable! (%d barrels, %d positions)", barrel_count, positions:length())
      return false
   end

   for _, x, y in positions:unwrap() do
      local barrel = barrels:filter(function(b) return b.x == x and b.y == y end):nth(1)
      if barrel then
         found[barrel] = true
      end
   end

   return table.count(found) == barrel_count
end

local function pad_layout_string(str)
   local lines = string.split(str, "\n")

   local max_len = fun.iter(lines):map(string.len):max()
   local pad = function(l)
      return l .. string.rep(" ", max_len - string.len(l))
   end
   local concat = function(acc, s) return (acc and (acc .. "\n") or "") .. s end

   return fun.iter(lines):map(pad):foldl(concat)
end

function SokobanMap.generate(board_id)
   local board_data = data["sokoban.board"]:ensure(board_id)

   local tiles = pad_layout_string(board_data.board)

   local tileset = {
      [" "] = "elona.cyber_4",
      ["#"] = "elona.wall_stone_3_top",
      ["."] = "elona.cyber_3",
      ["$"] = "elona.cyber_4",
      ["*"] = "elona.cyber_3",
      ["@"] = "elona.cyber_4",
      ["+"] = "elona.cyber_3",
   }

   local callbacks = {
      ["$"] = function(map, x, y)
         Feat.create("sokoban.barrel", x, y, {}, map)
      end,
      ["*"] = function(map, x, y)
         Feat.create("sokoban.barrel", x, y, {}, map)
      end,
      ["@"] = function(map, x, y)
         map.player_start_pos = { x = x, y = y }
         Item.create("elona.tight_rope", x, y, {}, map)
      end,
      ["+"] = function(map, x, y)
         map.player_start_pos = { x = x, y = y }
         Item.create("elona.tight_rope", x, y, {}, map)
      end
   }

   local map = Layout.to_map {
      tiles = tiles,
      tileset = tileset,
      callbacks = callbacks
   }
   map:set_archetype("sokoban.quest_sokoban", { set_properties = true })

   return map
end

return SokobanMap
