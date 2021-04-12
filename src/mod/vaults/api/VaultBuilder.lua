local Enum = require("api.Enum")
local VaultTilemap = require("mod.vaults.api.VaultTilemap")
local Feat = require("api.Feat")
local Item = require("api.Item")
local Area = require("api.Area")
local InstancedMap = require("api.InstancedMap")
local Log = require("api.Log")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")
local Rand = require("api.Rand")
local WeightedSampler = require("mod.tools.api.WeightedSampler")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.elona.api.Itemgen")

local VaultBuilder = class.class("VaultBuilder")

VaultBuilder.Orient = Enum.new("Orient", {
   Minivault = "minivault",
   Float = "float",
   Encompass = "encompass",
   North = "north",
   Northwest = "northwest",
   West = "west",
   Southwest = "southwest",
   South = "south",
   Southeast = "southeast",
   East = "east",
   Northeast = "northeast",
})

function VaultBuilder:init(tilemap)
   self._tags = table.set {}
   self._orient = VaultBuilder.Orient.Minivault

   self.width, self.height, self.tiles = VaultTilemap.extract_params(tilemap)

   self._weight = 10
   self._tileset = "vaults.default"
   self.tilemap = {
      ["."] = "vaults.builder_floor",
      ["x"] = "vaults.builder_rock_wall",
      ["c"] = "vaults.builder_stone_wall",
      ["v"] = "vaults.builder_metal_wall",
      ["b"] = "vaults.builder_crystal_wall",
      ["w"] = "vaults.builder_deep_water",
      ["W"] = "vaults.builder_shallow_water",
   }
   self.callbacks = {
      ["$"] = function(map, x, y)
         Item.create("elona.gold_piece", x, y, {}, map)
      end,
      ["*"] = function(map, x, y)
         local filter = {
            categories = Rand.choice(Filters.fsetwear),
            quality = Enum.Quality.Normal
         }
         Itemgen.create(x, y, filter, map)
      end,
      ["|"] = function(map, x, y)
         local filter = {
            categories = Rand.choice(Filters.fsetwear),
            quality = Enum.Quality.Good
         }
         Itemgen.create(x, y, filter, map)
      end,
      ["T"] = function(map, x, y)
         Item.create("elona.fountain", x, y, {}, map)
      end,
      ["+"] = function(map, x, y)
         Feat.create("elona.door", x, y, {}, map)
      end,
      ["}"] = function(map, x, y, area, floor)
         assert(Area.create_stairs_down(area, floor+1, x, y, {}, map))
      end,
      ["{"] = function(map, x, y, area, floor)
         if floor == 1 then
            local parent_area = Area.parent(area)
            local _, _, floor = parent_area:child_area_position(area)
            assert(Area.create_stairs_up(parent_area, floor, x, y, {}, map))
         else
            assert(Area.create_stairs_up(area, floor-1, x, y, {}, map))
         end
      end,
   }
end

function VaultBuilder:tags(tag)
   self._tags[tag] = true
end

function VaultBuilder:orient(orient)
   assert(VaultBuilder.Orient:has_value(orient))
   self._orient = orient
end

function VaultBuilder:tileset(tileset)
   data["elona_sys.map_tileset"]:ensure(tileset)
   self._tileset = tileset
end

function VaultBuilder:weight(weight)
   local weight_num = tonumber(weight)
   if not weight_num then
      error("Invalid weight " .. tostring(weight))
   end
   self._weight = weight_num
end

function VaultBuilder:mons(mons)
end

function VaultBuilder:subst(subst)
   assert(subst:len() > 2)
   local placeholders = {}
   local subst_type = nil
   local pos = nil
   local i = 1

   for _, c in fun.iter(fun.dup(string.chars(subst))) do
      Log.warn("%s, %s", i, c)
      if i == 1 then
         placeholders[c] = true
      elseif c == "=" or c == ":" then
         subst_type = c

         pos = i + 1
         break
      end
      i = i + 1
   end

   if subst_type == nil then
      error("Invalid subst " .. subst)
   end

   local sampler = WeightedSampler:new()

   local rest = string.split(subst:sub(pos), " ")
   for _, s in fun.iter(rest):filter(function(s) return s ~= "" end) do
      local colon_pos = s:find(":")
      if colon_pos then
         local chars = s:sub(1, colon_pos - 1)
         local weight = s:sub(colon_pos + 1)
         local weight_num = tonumber(weight)
         if not weight_num then
            error("Invalid weight " .. tostring(weight))
         end
         for c in string.chars(chars) do
            sampler:add(c, weight_num)
         end
      else
         for c in string.chars(s) do
            sampler:add(c, 10)
         end
      end
   end

   if sampler:len() == 0 then
      return
   end

   local new_tile
   if subst_type == ":" then
      new_tile = sampler:sample()
   end

   for idx, tile in ipairs(self.tiles) do
      if placeholders[tile] then
         if subst_type == "=" then
            new_tile = sampler:sample()
         end
         self.tiles[idx] = new_tile
      end
   end
end

function VaultBuilder:nsubst(nsubst)
   assert(nsubst:len() > 2)
   local placeholders = {}
   local pos = nil

   local run_subst = function(subst)
      subst = string.strip_whitespace(subst)

      local num = ""
      local subst_type = nil
      local subst_count = nil
      local pos = nil
      local i = 1

      for _, c in fun.iter(fun.dup(string.chars(subst))) do
         if c:match("[0-9*]") then
            num = num .. c
         elseif c == "=" or c == ":" then
            subst_type = c

            if num == "*" then
               subst_count = "*"
            else
               subst_count = tonumber(num)
               if subst_count == nil then
                  error("Invalid nsubst substitution " .. subst)
               end
            end

            pos = i + 1
            break
         end
         i = i + 1
      end

      if pos == nil then
         error("Invalid nsubst substitution " .. subst)
      end

      local sampler = WeightedSampler:new()

      local rest = string.split(subst:sub(pos), " ")
      for _, s in fun.iter(rest):filter(function(s) return s ~= "" end) do
         local colon_pos = s:find(":")
         if colon_pos then
            local chars = s:sub(1, colon_pos - 1)
            local weight = s:sub(colon_pos + 1)
            local weight_num = tonumber(weight)
            if not weight_num then
               error("Invalid weight " .. tostring(weight) .. " " .. s)
            end
            for c in string.chars(chars) do
               sampler:add(c, weight_num)
            end
         else
            for c in string.chars(s) do
               sampler:add(c, 10)
            end
         end
      end

      if sampler:len() == 0 then
         return
      end

      local new_tile
      if subst_type == ":" then
         new_tile = sampler:sample()
      end

      local choices = {}

      for idx, tile in ipairs(self.tiles) do
         if placeholders[tile] then
            choices[#choices+1] = idx
         end
      end

      Rand.shuffle(choices)

      local limit = subst_count
      if limit == "*" then
         limit = #choices
      end

      for i = 1, limit do
         local idx = choices[i]
         if subst_type == "=" then
            new_tile = sampler:sample()
         end
         self.tiles[idx] = new_tile
      end
   end

   nsubst = string.strip_whitespace(nsubst)

   local i = 1
   for _, c in fun.iter(fun.dup(string.chars(nsubst))) do
      if i == 1 then
         placeholders[c] = true
      elseif c == "=" then
         pos = i + 1
         break
      end
      i = i + 1
   end

   if pos == nil then
      error("Invalid nsubst " .. nsubst)
   end

   local rest = string.split(nsubst:sub(pos), "/")
   for _, subst in ipairs(rest) do
      run_subst(subst)
   end
end

function VaultBuilder:shuffle(shuffle)
   local shuffles = VaultTilemap.make_shuffle(shuffle)

   local do_shuffle = function(shuffle)
      local mapping = {}
      for idx, tile in ipairs(self.tiles) do
         local to = shuffle[tile]
         if to then
            mapping[idx] = to
         end
      end
      for idx, to in pairs(mapping) do
         self.tiles[idx] = to
      end
   end

   fun.iter(shuffles):each(do_shuffle)
end

function VaultBuilder:build_raw(area, floor)
   class.assert_is_an("api.InstancedArea", area)
   assert(math.type(floor) == "integer")
   local map = InstancedMap:new(self.width, self.height)
   map.tileset = self._tileset

   local exits = {}

   for idx, tile in ipairs(self.tiles) do
      local x = (idx-1) % self.width
      local y = math.floor((idx-1) / self.width)

      local map_tile, callback

      if tile == "@" then
         map_tile = "vaults.builder_floor"
         callback = nil
         exits[#exits+1] = { x = x, y = y }
      else
         map_tile = self.tilemap[tile]
         callback = self.callbacks[tile]
      end

      if map_tile == nil then
         if callback == nil then
            Log.warn("Missing tile '%s' in vault tilemap", tile)
         end
         map_tile = "vaults.builder_floor"
      end
      map:set_tile(x, y, map_tile)

      if callback then
         callback(map, x, y, area, floor)
      end
   end

   return map, exits
end

function VaultBuilder:rotate_map(clockwise)
   if self._tags["no_rotate"] then
      return
   end

   local xs, xe, xi, ys, ye, yi
   if clockwise then
      xs = 0
      xe = self.width
      xi = 1
      ys = self.height - 1
      ye = -1
      yi = -1
   else
      xs = self.width - 1
      xe = -1
      xi = -1
      ys = 0
      ye = self.height
      yi = 1
   end

   local new = {}

   for i = xs, xe-1, xi do
      for j = ys, ye-1, yi do
         local idx = i + j * self.width + 1
         new[#new+1] = self.tiles[idx]
      end
   end

   self.tiles = new

   local tmp = self.width
   self.width = self.height
   self.height = tmp
end

function VaultBuilder:swap(x1, y1, x2, y2)
   local idx1 = x1 + y1 * self.width + 1
   local idx2 = x2 + y2 * self.width + 1

   local tmp = self.tiles[idx1]
   self.tiles[idx1] = self.tiles[idx2]
   self.tiles[idx2] = tmp
end

function VaultBuilder:vmirror_map()
   if self._tags["no_vmirror"] then
      return
   end

   local midpoint = math.floor(self.height / 2) - 1

   for i = 0, self.width - 1 do
      for j = 0, midpoint do
         self:swap(i, j, i, self.height - 1 - j)
      end
   end
end

function VaultBuilder:hmirror_map()
   if self._tags["no_hmirror"] then
      return
   end

   local midpoint = math.floor(self.width / 2) - 1

   for i = 0, midpoint do
      for j = 0, self.height - 1 do
         self:swap(i, j, self.width - 1 - i, j)
      end
   end
end

function VaultBuilder:build(area, floor)
   if Rand.one_in(2) then
      self:rotate_map(Rand.one_in(2) == 0)
   end

   if Rand.one_in(2) then
      self:vmirror_map()
   end

   if Rand.one_in(2) then
      self:hmirror_map()
   end

   return self:build_raw(area, floor)
end

function VaultBuilder.test()
   local test = require("mod.vaults.data.vaults.test2")

   local builder = VaultBuilder:new(test.map)
   test.main(builder)
   local map, exits = builder:build(Area.current(), 20)

   local parent = InstancedMap:new(math.max(50, builder.width), math.max(50, builder.height))
   parent:clear("vaults.builder_rock_wall")
   parent.tileset = map.tileset

   parent:splice(map, parent:width() / 2 - map:width() / 2, parent:height() / 2 - map:height() / 2)

   MapTileset.apply(parent.tileset, parent)

   return parent
end

return VaultBuilder
