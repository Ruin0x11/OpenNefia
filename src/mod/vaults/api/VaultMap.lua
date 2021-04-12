local Rand = require("api.Rand")
local VaultBuilder = require("mod.vaults.api.VaultBuilder")
local InstancedMap = require("api.InstancedMap")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Feat = require("api.Feat")
local Log = require("api.Log")
local Pos = require("api.Pos")

local VaultMap = {}

function VaultMap.proc_chance(chance, area, floor, level)
   if type(chance) ~= "table" or #chance == 0 then
      chance = { chance }
   end

   for _, ch in ipairs(chance) do
      if type(ch) == "number" then
         if Rand.percent_chance(ch) then
            return true
         end
      end

      local ty = ch.type
      local chance = ty.chance or 100
      local invert = not not ty.invert

      if ty == "floor" then
         local min = ch.min
         local max = ch.max
         local choose
         if invert then
            choose = (min == nil or floor < min) and (max == nil or floor > max)
         else
            choose = (min == nil or floor >= min) and (max == nil or floor <= max)
         end
         if choose and Rand.percent_chance(chance) then
            return true
         end
      elseif ty == "level" then
         local min = ch.min
         local max = ch.max
         local choose
         if invert then
            choose = (min == nil or level < min) and (max == nil or level > max)
         else
            choose = (min == nil or level >= min) and (max == nil or level <= max)
         end
         if choose and Rand.percent_chance(chance) then
            return true
         end
      else
         error("Invalid chance type " .. tostring(ty))
      end
   end

   return false
end

function VaultMap.random_vault_for_tag(area, floor, tag)
   local filter = function(vault)
      return vault.tags(area, floor)[tag]
   end

   return Rand.choice(data["vaults.vault"]:iter():filter(filter):extract("_id"))
end

function VaultMap.random_vault_for_place(area, floor, want_minivault)
   return nil
end

function VaultMap.can_use_in(vault, area, floor)
   local tags = vault.tags(area, floor)
   return not tags["entry"]
end

function VaultMap.proc_generate(vault, area, floor, level, want_minivault)
   if vault.chance == nil then
      return false
   end

   if vault.is_minivault and not want_minivault then
      return false
   elseif not vault.is_minivault and want_minivault then
      return false
   end

   if not VaultMap.proc_chance(vault.chance(area, floor), area, floor, level) then
      return false
   end

   return VaultMap.can_use_in(vault, area, floor)
end

function VaultMap.random_vault_for_area(area, floor, want_minivault)
   local filter = function(vault)
      -- TODO
      local level = floor
      return VaultMap.proc_generate(vault, area, floor, level, want_minivault)
   end

   return Rand.choice(data["vaults.vault"]:iter():filter(filter):extract("_id"))
end

function VaultMap.random_vault(area, floor, want_minivault)
   if floor == 1 then
      return VaultMap.random_vault_for_tag(area, floor, "arrival")
   end

   return VaultMap.random_vault_for_place(area, floor, want_minivault)
end

function VaultMap.random_primary_vault(area, floor)
   local vault = VaultMap.random_vault(area, floor, false)

   if vault == nil then
      vault = VaultMap.random_vault_for_area(area, floor, false)
   end

   return vault
end

local function can_overwrite(map, tx, ty, can_overwrite_floor_tiles, mask)
   if can_overwrite_floor_tiles then
      if not map:is_floor(tx, ty) then
         return false
      end
      -- TODO capability data for existing vaults in map
   elseif mask[tx] and mask[tx][ty] then
      return false
   end

   if Chara.at(tx, ty, map) then
      return false
   end
   if Item.at(tx, ty, map):length() > 0 then
      return false
   end

   -- TODO data extension: whitelist overwriteable feats (doors)
   if Feat.at(tx, ty, map):length() > 0 then
      return false
   end

   return true
end

local function is_vault_placement_valid(map, vault_map, tags, x, y, mask)
   local can_overwrite_floor_tiles = tags["overwrite_floor_tiles"]

   for _, ox, oy in vault_map:iter_tiles() do
      local tx, ty = x + ox, y + oy

      if not can_overwrite(map, tx, ty, can_overwrite_floor_tiles, mask) then
         return false
      end
   end

   return true
end

local function float_pos(map, vault_map)
   local min_hborder = 13
   local min_vborder = min_hborder

   if map:width() - 2 * min_hborder < vault_map:width() then
      min_hborder = math.floor((map:width() - vault_map:width()) / 2 - 1)
   end
   if map:height() - 2 * min_vborder < vault_map:height() then
      min_vborder = math.floor((map:height() - vault_map:height()) / 2 - 1)
   end

   local x = Rand.between(min_hborder, map:width() - min_hborder - vault_map:width())
   local y = Rand.between(min_vborder, map:height() - min_vborder - vault_map:height())

   return x, y
end

local function find_vault_pos(map, vault_map, orient, tags, check_collisions, mask)
   local Orient = VaultBuilder.Orient

   local x, y = 0, 0
   local mw, mh = map:width(), map:height()
   local vw, vh = vault_map:width(), vault_map:height()

   if orient == Orient.South
      or orient == Orient.Southeast
      or orient == Orient.Southwest
   then
      y = mh - vh
   end

   if orient == Orient.East
      or orient == Orient.Northeast
      or orient == Orient.Northwest
   then
      x = mw - vw
   end

   if (orient == Orient.North
       or orient == Orient.South
       or orient == Orient.Encompass
       or orient == Orient.Center)
      and vw < mw
   then
      x = math.floor((mw - vw) / 2)
   end

   if (orient == Orient.East
       or orient == Orient.West
       or orient == Orient.Encompass
       or orient == Orient.Center)
      and vh < mh
   then
      y = math.floor((mh - vh) / 2)
   end

   if orient == Orient.Float then
      x, y = float_pos(map, vault_map)
   end

   if not map:is_in_bounds(x, y) then
      return nil, nil
   end

   if check_collisions and not is_vault_placement_valid(map, vault_map, tags, x, y, mask) then
      return nil, nil
   end

   return x, y
end

local function place_vault(vault_id, map, area, floor, check_collisions, mask)
   local tries = 25

   Log.warn("Try to place vault %s", vault_id)

   for i = 1, tries do
      local builder = VaultBuilder:new(vault_id)
      local vault_map, exits, tags = builder:build(area, floor)
      if vault_map then
         local orient = builder._orient

         local x, y = find_vault_pos(map, vault_map, orient, tags, check_collisions, mask)

         if x and y then
            map:splice(vault_map, x, y)
            for _, ox, oy in vault_map:iter_tiles() do
               local tx = x + ox
               local ty = y + oy
               mask[tx] = mask[tx] or {}
               mask[tx][ty] = true
            end
            Log.warn("Placed vault %s at %d,%d orient %s", vault_id, x, y, orient)
            return orient, exits
         end
      end

   end

   return nil
end

local function get_connecting_path(map, exit, mask)
   local ex = exit.x
   local ey = exit.y

   local function can_pass(x, y)
      local border = 4
      -- TODO capability data for existing vaults in map
      return x >= border and y >= border
         and x < map:width() - border and y < map:height() - border
         and not (mask[x] and mask[x][y])
   end

   local tiles = {}
   for _, x, y in Pos.iter_surrounding_orth(ex, ey):filter(can_pass) do
      tiles[#tiles+1] = { x = x, y = y }
   end

   local path = {}
   local seen = {}
   local success = false

   while next(tiles) and not success do
      local key = Rand.choice(table.keys(tiles))
      local pos = tiles[key]
      tiles[key] = nil
      seen[pos.x] = seen[pos.x] or {}
      seen[pos.x][pos.y] = true

      path[#path+1] = pos

      for _, x, y in Pos.iter_surrounding_orth(pos.x, pos.y) do
         local tile = map:tile(x, y)
         if tile._id == "vaults.builder_floor" then
            success = true
         end

         path[#path+1] = { x = x, y = y }
         seen[x] = seen[x] or {}
         seen[x][y] = true

         if can_overwrite(map, x, y, false, mask) then
            for _, x, y in Pos.iter_surrounding(pos.x, pos.y):filter(can_pass) do
               if not seen[x] or not seen[x][y] then
                  tiles[#tiles+1] = { x = x, y = y }
               end
            end
         end
      end
   end

   if success then
      return path
   end

   return nil
end

local function connect_vault_exit(map, exit, mask)
   local path = get_connecting_path(map, exit, mask)
   if path then
      for _, pos in ipairs(path) do
         map:set_tile(pos.x, pos.y, "vaults.builder_floor")
      end
   end

   return path
end

local function place_secondary_vaults(map, area, floor, mask)
   local filter = function(vault)
      -- TODO
      local level = floor
      return VaultMap.proc_generate(vault, area, floor, level, false)
   end

   for _, chance_vault in data["vaults.vault"]:iter():filter(filter):extract("_id") do
      local orient, exits = place_vault(chance_vault, map, area, floor, true, mask)
      if orient then
         Log.warn("EXITS %s", inspect(exits))
         for _, exit in ipairs(exits) do
            if not connect_vault_exit(map, exit, mask) then
               Log.error("Could not connect vault exit %d,%d", exit.x, exit.y)
            end
         end
      end
   end
end

function VaultMap.generate(area, floor)
   local primary = VaultMap.random_primary_vault(area, floor)

   local parent = InstancedMap:new(100, 100)
   parent:clear("vaults.builder_empty")
   parent.tileset = "vaults.default"

   local mask = {}

   local orient = place_vault(primary, parent, area, floor, false, mask)

   if orient ~= VaultBuilder.Orient.Encompass then
      place_secondary_vaults(parent, area, floor, mask)
   end

   for _, ox, oy, tile in parent:iter_tiles() do
      if tile._id == "vaults.builder_empty" then
         parent:set_tile(ox, oy, "vaults.builder_rock_wall")
      end
   end

   MapTileset.apply(parent.tileset, parent)

   parent:set_archetype("vaults.vault", { set_properties = true })

   return parent
end

return VaultMap
