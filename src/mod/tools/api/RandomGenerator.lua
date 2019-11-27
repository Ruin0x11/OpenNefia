--- Implements the random generator from the HSP runtime.
--- Borrowed from https://www.github.com/ki-foobar/lws-cpp.
--- @module RandomGenerator

--[[
This class is based on a HSP's DLL, EXRand.

0〜32kじゃ何もできん!! 拡張乱数 EXRand
(c)2002 D.N.A. Softwares
このDLLはフリーソフトウェアです。


乱数生成部は松本眞氏と西村拓士氏による
Mersenne Twisterを使用しています。a


Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

3. The names of its contributors may not be used to endorse or promote
products derived from this software without specific prior written
permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

local RandomGenerator = class.class("RandomGenerator")

local N = 624
local M = 397
local MATRIX_A = 0x9908B0DF
local UMASK    = 0x80000000
local LMASK    = 0x7fffffff

function RandomGenerator:init(seed)
   self.left = 1
   self.initf = false
   self.next_ind = 1
   self.state = table.of(0, N)
   self.seed = seed or 0
   self:_init_genrand(self.seed)
end

function RandomGenerator:_init_genrand(seed)
   self.state[0] = bit.band(seed, 0xFFFFFFFF)
   for j = 2, N do
      self.state[j] = (1812433253 * bit.bxor(self.state[j - 1], bit.rshift(self.state[j - 1], 30)) + j)
      self.state[j] = bit.band(self.state[j], 0xffffffff)
   end
   self.left = 1
   self.initf = true
end

function RandomGenerator:randomize(seed)
   self.seed = seed or 0
   self:_init_genrand(seed)
end

local function mixbits(u, v)
   return bit.bor(bit.band(u, UMASK), bit.band(v, LMASK))
end

local function twist(u, v)
   local l = MATRIX_A
   if bit.band(v, 1) == 1 then
      l = 0
   end
   return bit.bxor(bit.rshift(mixbits(u, v), 1), l)
end

function RandomGenerator:_next_state()
   local j = 1

   if self.initf == false then
      self:_init_genrand(5489)
   end

   self.left = N
   self.next_ind = 1

   for _ = 1, N - M do
      self.state[j] = bit.bxor(self.state[j+M], twist(self.state[j], self.state[j+1]))
      j = j + 1
   end
   for _ = 1, M - 1 do
      self.state[j] = bit.bxor(self.state[j+M-N], twist(self.state[j], self.state[j+1]))
      j = j + 1
   end

   self.state[j] = bit.bxor(self.state[j+M-N], twist(self.state[j], self.state[1]))
end

function RandomGenerator:_genrand_real2()
   self.left = self.left - 1
   if self.left == 0 then
      self:_next_state()
   end

   local y = self.state[self.next_ind]
   y = bit.bxor(y, bit.rshift(y, 11))
   y = bit.bxor(y, bit.band(bit.lshift(y, 7), 0x9D2C5680))
   y = bit.bxor(y, bit.band(bit.lshift(y, 15), 0xEFC60000))
   y = bit.bxor(y, bit.rshift(y, 18))

   self.next_ind = self.next_ind + 1

   return y * (1.0 / 4294967296.0)
end

function RandomGenerator:rnd(n)
   self.seed = self.seed * 214013 + 2531011
   return bit.band(bit.rshift(self.seed, 16), 0x7FFF) % n
end

function RandomGenerator:rndex(n)
   return math.floor(self:_genrand_real2() * n + n / 2)
end

return RandomGenerator
