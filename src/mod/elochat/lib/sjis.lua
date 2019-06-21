--[[
   THE C-KERMIT 9.0 LICENSE

   Fri Jun 24 14:43:35 2011

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   + Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   + Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.

   + Neither the name of Columbia University nor the names of any
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

local sjis_tables = require("mod.elochat.lib.sjis_tables")

local sju_8140 = sjis_tables.sju_8140
local sju_e040 = sjis_tables.sju_e040

local usj_0391 = sjis_tables.usj_0391
local usj_0401 = sjis_tables.usj_0401
local usj_3000 = sjis_tables.usj_3000
local usj_ff00 = sjis_tables.usj_ff00
local usj_4e00 = sjis_tables.usj_4e00

local sjis = {}

function sjis.unicode_to_sjis(un)
   -- Single-byte characters
   if un < 0x00a0 then
      if     un == 0x005c then return 0x815f -- Backslash
      elseif un == 0x007e then return 0xfffd -- No tilde in Shift-JIS
      else                     return un     -- ASCII or C0/C1 control
      end
   end

   -- Latin-1 symbols
   if un >= 0x00a0 and un < 0x0391 then
      if     un == 0x00A2 then return 0x8191
      elseif un == 0x00A3 then return 0x8192
      elseif un == 0x00A5 then return 0x005C -- Yen
      elseif un == 0x00A7 then return 0x8198
      elseif un == 0x00A8 then return 0x814E
      elseif un == 0x00AC then return 0x81CA
      elseif un == 0x00B0 then return 0x818B
      elseif un == 0x00B1 then return 0x817D
      elseif un == 0x00B4 then return 0x814C
      elseif un == 0x00B6 then return 0x81F7
      elseif un == 0x00D7 then return 0x817E
      elseif un == 0x00F7 then return 0x8180
      else                     return 0xfffd
      end
   end

   -- Greek
   if un >= 0x0391 and un < 0x0401 then
      if un <= 0x039c then
         return usj_0391[un-0x0391+1]
      end

      return 0xfffd
   end

   -- Cyrillic
   if un >= 0x0401 and un < 0x2010 then
      if un <= 0x0451 then
         return usj_0401[un-0x0401+1]
      end

      return 0xfffd;
   end

   -- General punctuation
   if un >= 0x2010 and un < 0x2500 then
      if     un == 0x2010 then return 0x815D
      elseif un == 0x2015 then return 0x815C
      elseif un == 0x2016 then return 0x8161
      elseif un == 0x2018 then return 0x8165
      elseif un == 0x2019 then return 0x8166
      elseif un == 0x201C then return 0x8167
      elseif un == 0x201D then return 0x8168
      elseif un == 0x2020 then return 0x81F5
      elseif un == 0x2021 then return 0x81F6
      elseif un == 0x2025 then return 0x8164
      elseif un == 0x2026 then return 0x8163
      elseif un == 0x2030 then return 0x81F1
      elseif un == 0x2032 then return 0x818C
      elseif un == 0x2033 then return 0x818D
      elseif un == 0x203B then return 0x81A6
      elseif un == 0x203E then return 0x007E
      elseif un == 0x2103 then return 0x818E -- Letterlike symbols
      elseif un == 0x212B then return 0x81F0
      elseif un == 0x2190 then return 0x81A9 -- Arrows
      elseif un == 0x2191 then return 0x81AA
      elseif un == 0x2192 then return 0x81A8
      elseif un == 0x2193 then return 0x81AB
      elseif un == 0x21D2 then return 0x81CB
      elseif un == 0x21D4 then return 0x81CC
      elseif un == 0x2200 then return 0x81CD -- Math
      elseif un == 0x2202 then return 0x81DD
      elseif un == 0x2203 then return 0x81CE
      elseif un == 0x2207 then return 0x81DE
      elseif un == 0x2208 then return 0x81B8
      elseif un == 0x220B then return 0x81B9
      elseif un == 0x2212 then return 0x817C
      elseif un == 0x221A then return 0x81E3
      elseif un == 0x221D then return 0x81E5
      elseif un == 0x221E then return 0x8187
      elseif un == 0x2220 then return 0x81DA
      elseif un == 0x2227 then return 0x81C8
      elseif un == 0x2228 then return 0x81C9
      elseif un == 0x2229 then return 0x81BF
      elseif un == 0x222A then return 0x81BE
      elseif un == 0x222B then return 0x81E7
      elseif un == 0x222C then return 0x81E8
      elseif un == 0x2234 then return 0x8188
      elseif un == 0x2235 then return 0x81E6
      elseif un == 0x223D then return 0x81E4
      elseif un == 0x2252 then return 0x81E0
      elseif un == 0x2260 then return 0x8182
      elseif un == 0x2261 then return 0x81DF
      elseif un == 0x2266 then return 0x8185
      elseif un == 0x2267 then return 0x8186
      elseif un == 0x226A then return 0x81E1
      elseif un == 0x226B then return 0x81E2
      elseif un == 0x2282 then return 0x81BC
      elseif un == 0x2283 then return 0x81BD
      elseif un == 0x2286 then return 0x81BA
      elseif un == 0x2287 then return 0x81BB
      elseif un == 0x22A5 then return 0x81DB
      elseif un == 0x2312 then return 0x81DC -- Arc
      else                     return 0xfffd
      end
   end

   -- Box drawing
   if un >= 0x2500 and un < 0x3000 then
      if     un == 0x2500 then return 0x849F
      elseif un == 0x2501 then return 0x84AA
      elseif un == 0x2502 then return 0x84A0
      elseif un == 0x2503 then return 0x84AB
      elseif un == 0x250C then return 0x84A1
      elseif un == 0x250F then return 0x84AC
      elseif un == 0x2510 then return 0x84A2
      elseif un == 0x2513 then return 0x84AD
      elseif un == 0x2514 then return 0x84A4
      elseif un == 0x2517 then return 0x84AF
      elseif un == 0x2518 then return 0x84A3
      elseif un == 0x251B then return 0x84AE
      elseif un == 0x251C then return 0x84A5
      elseif un == 0x251D then return 0x84BA
      elseif un == 0x2520 then return 0x84B5
      elseif un == 0x2523 then return 0x84B0
      elseif un == 0x2524 then return 0x84A7
      elseif un == 0x2525 then return 0x84BC
      elseif un == 0x2528 then return 0x84B7
      elseif un == 0x252B then return 0x84B2
      elseif un == 0x252C then return 0x84A6
      elseif un == 0x252F then return 0x84B6
      elseif un == 0x2530 then return 0x84BB
      elseif un == 0x2533 then return 0x84B1
      elseif un == 0x2534 then return 0x84A8
      elseif un == 0x2537 then return 0x84B8
      elseif un == 0x2538 then return 0x84BD
      elseif un == 0x253B then return 0x84B3
      elseif un == 0x253C then return 0x84A9
      elseif un == 0x253F then return 0x84B9
      elseif un == 0x2542 then return 0x84BE
      elseif un == 0x254B then return 0x84B4
      elseif un == 0x25A0 then return 0x81A1 -- Geometric shapes
      elseif un == 0x25A1 then return 0x81A0
      elseif un == 0x25B2 then return 0x81A3
      elseif un == 0x25B3 then return 0x81A2
      elseif un == 0x25BC then return 0x81A5
      elseif un == 0x25BD then return 0x81A4
      elseif un == 0x25C6 then return 0x819F
      elseif un == 0x25C7 then return 0x819E
      elseif un == 0x25CB then return 0x819B
      elseif un == 0x25CE then return 0x819D
      elseif un == 0x25CF then return 0x819C
      elseif un == 0x25EF then return 0x81FC
      elseif un == 0x2605 then return 0x819A -- Misc symbols
      elseif un == 0x2606 then return 0x8199
      elseif un == 0x2640 then return 0x818A
      elseif un == 0x2642 then return 0x8189
      elseif un == 0x266A then return 0x81F4
      elseif un == 0x266D then return 0x81F3
      elseif un == 0x266F then return 0x81F2
      else return 0xfffd end
   end

   -- CJK symbols & punc
   if un >= 0x3000 and un < 0x4e00 then
      if un <= 0x30ff then
         return usj_3000[un-0x3000+1]
      end

      return 0xfffd
   end

   -- Half/full-width Roman & Katakana
   if un >= 0xff00 and un < 0xffff then
      if un <= 0xff9f then
         return usj_ff00[un-0xff00+1]
      end

      return 0xfffd
   end

   -- Kanji
   if un >= 0x4e00 and un < 0xe000 then
      if un <= 0x9fa0 then
         return usj_4e00[un-0x4e00+1]
      end
      return 0xfffd
   end

   -- User-defined (Gaiji)
   if un >= 0xe000 and un < 0xff00 then
      -- ten 189-char chunks
      if un <= 0xe0bb then
         return 0xf040 + (un - 0xe000)
      elseif un >= 0xe0bc and un <= 0xe177 then
         return 0xf140 + (un - 0xe0bc)
      elseif un >= 0xe178 and un <= 0xe233 then
         return 0xf240 + (un - 0xe178)
      elseif un >= 0xe234 and un <= 0xe2ef then
         return 0xf340 + (un - 0xe234)
      elseif un >= 0xe2f0 and un <= 0xe3ab then
         return 0xf440 + (un - 0xe2f0)
      elseif un >= 0xe3ac and un <= 0xe467 then
         return 0xf540 + (un - 0xe3ac)
      elseif un >= 0xe468 and un <= 0xe523 then
         return 0xf640 + (un - 0xe468)
      elseif un >= 0xe524 and un <= 0xe5df then
         return 0xf740 + (un - 0xe524)
      elseif un >= 0xe5e0 and un <= 0xe69b then
         return 0xf840 + (un - 0xe5e0)
      elseif un >= 0xe69c and un <= 0xe757 then
         return 0xf940 + (un - 0xe69c)
      end

      return 0xfffd
   end

   return 0xfffd

end

function sjis.sjis_to_unicode(sj)
   -- Kanji blocks
   if sj >= 0x8140 then
      -- All possible Kanjis
      if sj <= 0x9ffc then
         -- 7869-element table
         return sju_8140[sj - 0x8140+1]
      elseif sj >= 0xe040 and sj <= 0xeaa4 then
         -- 2660-element table
         return sju_e040[sj - 0xe040+1]
      elseif sj >= 0xf040 then
         -- User-defined areas
         -- ten 189-char chunks
         if sj <= 0xf0fc then
            return 0xe000 + (sj - 0xf040)
         elseif sj >= 0xf140 and sj <= 0xf1fc then
            return 0xe0bc + (sj - 0xf140)
         elseif sj >= 0xf240 and sj <= 0xf2fc then
            return 0xe178 + (sj - 0xf240)
         elseif sj >= 0xf340 and sj <= 0xf3fc then
            return 0xe234 + (sj - 0xf340)
         elseif sj >= 0xf440 and sj <= 0xf4fc then
            return 0xe2f0 + (sj - 0xf440)
         elseif sj >= 0xf540 and sj <= 0xf5fc then
            return 0xe3ac + (sj - 0xf540)
         elseif sj >= 0xf640 and sj <= 0xf6fc then
            return 0xe468 + (sj - 0xf640)
         elseif sj >= 0xf740 and sj <= 0xf7fc then
            return 0xe524 + (sj - 0xf740)
         elseif sj >= 0xf840 and sj <= 0xf8fc then
            return 0xe5e0 + (sj - 0xf840)
         elseif sj >= 0xf940 and sj <= 0xf9fc then
            return 0xe69c + (sj - 0xf940)
         end
      end
   elseif sj < 0x00a0 then
      -- C0 / Halfwidth-Roman / C1 block (0x00-0x9f, no holes)
      if     sj == 0x5c then return 0x00a5 -- Yen sign
      elseif sj == 0x7e then return 0x203e -- Overline (macron)
      else                   return sj     -- Control or Halfwidth Roman
      end
   elseif sj >= 0xa1 and sj <= 0xdf then
      -- Halfwidth Katakana block (0xa0-0xdf, no holes)
      return sj + 0xfec0
   end

   return 0xfffd
end

local function iter_codes(a, i)
   local b = string.byte(a.s, i)
   if b == nil then
      return nil
   end

   if b <= 0x80 or (b >= 0xa0 and x <= 0xdf) then
      return i + 1, b
   else
      b = bit.bor(bit.lshift(b, 8), string.byte(a.s, i+ 1))
      return i + 2, b
   end
end

function sjis.codes(s)
   return iter_codes, {s=s}, 1
end

function sjis.to_utf8(s)
   local line = {}
   if type(s) == "table" then
      for _, c in ipairs(s) do
         line[#line+1] = sjis.sjis_to_unicode(c)
      end
   else
      for _, c in sjis.codes(s) do
         line[#line+1] = sjis.sjis_to_unicode(c)
      end
   end
   return utf8.char(unpack(line))
end

function sjis.from_utf8(s)
   local line = {}
   for _, c in utf8.codes(s) do
      line[#line+1] = sjis.unicode_to_sjis(c)
   end
   return line
end

return sjis
