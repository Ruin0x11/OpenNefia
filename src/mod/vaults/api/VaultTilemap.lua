local VaultTilemap = {}
local Rand = require("api.Rand")

local function split_layout_string(str, pad_tile)
   pad_tile = pad_tile or " "
   local lines = string.split(str, "\n")

   local max_len = fun.iter(lines):map(string.len):max()
   local pad = function(l)
      return l .. string.rep(pad_tile, max_len - string.len(l))
   end
   local concat = function(acc, s) return (acc and (acc .. "\n") or "") .. s end

   return fun.iter(lines):map(pad):to_list()
end

function VaultTilemap.extract_params(str)
   local split = split_layout_string(str)
   local width = split[1]:len()
   local height = #split
   local tiles = {}

   for i, s in ipairs(split) do
      if s:len() ~= width then
         error(("invalid row of width '%d' passed (expected '%d')"):format(s:len(), width))
      end
      for c in string.chars(s) do
         tiles[#tiles+1] = c
      end
   end

   return width, height, tiles
end

function VaultTilemap.make_shuffle(shuffle)
   local to_chars = function(s)
      return fun.iter(fun.dup(string.chars(s))):to_list()
   end

   local shuffles = fun.iter(string.split(shuffle, "/"))
      :map(string.strip_whitespace)
      :map(to_chars)
      :to_list()

   if #shuffles == 0 then
      return {}
   end

   local len = #shuffles[1]
   if fun.iter(shuffles):any(function(s) return #s ~= len end) then
      error("Shuffle blocks must all be of the same length. (" .. shuffle .. ")")
   end

   local permutation = fun.range(len):to_list()
   Rand.shuffle(permutation)

   local new = {}
   for i, shuffle in ipairs(shuffles) do
      new[i] = {}
      for j, idx in ipairs(permutation) do
         new[i][shuffle[j]] = shuffle[idx]
      end
   end

   return new
end

return VaultTilemap
