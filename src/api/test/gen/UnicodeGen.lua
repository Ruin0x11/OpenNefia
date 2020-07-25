local IGenerator = require("api.test.gen.IGenerator")
local IntGen = require("api.test.gen.IntGen")
local Rand = require("api.Rand")

local UnicodeGen = class.class("UnicodeGen", IGenerator)

local function is_reserved(cp)
   if cp < 0 or cp > 0x10FFFF then
      return true
   end

   if cp >= 0xDC00 and cp <= 0xDFFF then
      return true
   end

   if cp >= 0xD800 and cp <= 0xDBff then
      return true
   end

   local b = bit.band(cp, 0xFFFF)
   if b == 0xFFFE or b == 0xFFFF then
      return true
   end

   return false
end

local ASCII = {
   { 0x0, 0x7F }
}

-- Basic Multilingual Plane.
local PLANE_0 = {
   { 0xF0, 0xFFFF },
}

-- Supplementary Multilingual Plane.
local PLANE_1 = {
   { 0x10000, 0x10FFF },
   { 0x11000, 0x11FFF },
   { 0x12000, 0x12FFF },
   { 0x13000, 0x13FFF },
   { 0x1D000, 0x1DFFF },
   { 0x1F000, 0x1FFFF },
}

-- Supplementary Ideographic Plane.
local PLANE_2 = {
   { 0x20000, 0x20FFF },
   { 0x21000, 0x21FFF },
   { 0x22000, 0x22FFF },
   { 0x23000, 0x23FFF },
   { 0x24000, 0x24FFF },
   { 0x25000, 0x25FFF },
   { 0x26000, 0x26FFF },
   { 0x27000, 0x27FFF },
   { 0x28000, 0x28FFF },
   { 0x29000, 0x29FFF },
   { 0x2A000, 0x2AFFF },
   { 0x2B000, 0x2BFFF },
   { 0x2F000, 0x2FFFF },
}

-- Supplementary Special-Purpose Plane.
local PLANE_14 = {
   { 0xE0000, 0xE0FFF }
}

local PLANES = {
   { 60, ASCII },
   { 14, PLANE_0 },
   { 14, PLANE_1 },
   { 6, PLANE_2 },
   { 6, PLANE_14 },
}

function UnicodeGen:pick(size)
   local plane = self.sampler:sample()
   local gen = Rand.choice(plane)
   local cp = gen:pick(size)
   assert(not is_reserved(cp))

   return utf8.char(cp)
end


function UnicodeGen:shrink(prev)
   print(inspect(prev))
   local cp = self.int_gen:shrink(utf8.byte(prev))[1]
   if is_reserved(cp) then
      return {}
   end
   return { utf8.char(cp) }
end


function UnicodeGen:init(planes)
   local WeightedSampler = require("mod.tools.api.WeightedSampler")

   self.int_gen = IntGen:new()
   self.sampler = WeightedSampler:new()

   planes = planes or PLANES

   for _, pair in ipairs(planes) do
      local weight = pair[1]
      local plane = pair[2]

      local gens = fun.iter(plane):map(function(p) return IntGen:new(p[1], p[2]) end):to_list()

      self.sampler:add(gens, weight)
   end
end

local PLANE_CJK_SYMBOLS = {
   { 0x3000, 0x303F }
}

local PLANE_HIRAGANA = {
   { 0x30A0, 0x30FF }
}

local PLANE_KATAKANA = {
   { 0x3040, 0x309F }
}

local PLANE_HALFWIDTH_FULLWIDTH = {
   { 0xFF00, 0xFFEF }
}

local PLANE_CJK_UNIFIED_IDEOGRAPHS = {
   { 0x4E00, 0x9FAF }
}

local PLANES_KANA = {
   { 10, PLANE_CJK_SYMBOLS },
   { 20, PLANE_HIRAGANA },
   { 20, PLANE_KATAKANA },
   { 10, PLANE_HALFWIDTH_FULLWIDTH },
   { 40, PLANE_CJK_UNIFIED_IDEOGRAPHS },
}

function UnicodeGen:new_kana()
   return UnicodeGen:new(PLANES_KANA)
end


return UnicodeGen
