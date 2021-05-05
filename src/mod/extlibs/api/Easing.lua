--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
--

--[[
Disclaimer for Robert Penner's Easing Equations license:

TERMS OF USE - EASING EQUATIONS

Open source under the BSD License.

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- For all easing functions:
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)

local pow = math.pow
local sin = math.sin
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt
local abs = math.abs
local asin  = math.asin

local Easing = {}

function Easing.linear(t, b, c, d)
  return c * t / d + b
end

function Easing.inQuad(t, b, c, d)
  t = t / d
  return c * pow(t, 2) + b
end

function Easing.outQuad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end

function Easing.inOutQuad(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 2) + b
  else
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end
end

function Easing.outInQuad(t, b, c, d)
  if t < d / 2 then
    return Easing.outQuad (t * 2, b, c / 2, d)
  else
    return Easing.inQuad((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.inCubic (t, b, c, d)
  t = t / d
  return c * pow(t, 3) + b
end

function Easing.outCubic(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 3) + 1) + b
end

function Easing.inOutCubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * t * t * t + b
  else
    t = t - 2
    return c / 2 * (t * t * t + 2) + b
  end
end

function Easing.outInCubic(t, b, c, d)
  if t < d / 2 then
    return Easing.outCubic(t * 2, b, c / 2, d)
  else
    return Easing.inCubic((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.inQuart(t, b, c, d)
  t = t / d
  return c * pow(t, 4) + b
end

function Easing.outQuart(t, b, c, d)
  t = t / d - 1
  return -c * (pow(t, 4) - 1) + b
end

function Easing.inOutQuart(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 4) + b
  else
    t = t - 2
    return -c / 2 * (pow(t, 4) - 2) + b
  end
end

function Easing.outInQuart(t, b, c, d)
  if t < d / 2 then
    return Easing.outQuart(t * 2, b, c / 2, d)
  else
    return Easing.inQuart((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.inQuint(t, b, c, d)
  t = t / d
  return c * pow(t, 5) + b
end

function Easing.outQuint(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 5) + 1) + b
end

function Easing.inOutQuint(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 5) + b
  else
    t = t - 2
    return c / 2 * (pow(t, 5) + 2) + b
  end
end

function Easing.outInQuint(t, b, c, d)
  if t < d / 2 then
    return Easing.outQuint(t * 2, b, c / 2, d)
  else
    return Easing.inQuint((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.inSine(t, b, c, d)
  return -c * cos(t / d * (pi / 2)) + c + b
end

function Easing.outSine(t, b, c, d)
  return c * sin(t / d * (pi / 2)) + b
end

function Easing.inOutSine(t, b, c, d)
  return -c / 2 * (cos(pi * t / d) - 1) + b
end

function Easing.outInSine(t, b, c, d)
  if t < d / 2 then
    return Easing.outSine(t * 2, b, c / 2, d)
  else
    return Easing.inSine((t * 2) -d, b + c / 2, c / 2, d)
  end
end

function Easing.inExpo(t, b, c, d)
  if t == 0 then
    return b
  else
    return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
  end
end

function Easing.outExpo(t, b, c, d)
  if t == d then
    return b + c
  else
    return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
  end
end

function Easing.inOutExpo(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
  else
    t = t - 1
    return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
  end
end

function Easing.outInExpo(t, b, c, d)
  if t < d / 2 then
    return Easing.outExpo(t * 2, b, c / 2, d)
  else
    return Easing.inExpo((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.inCirc(t, b, c, d)
  t = t / d
  return(-c * (sqrt(1 - pow(t, 2)) - 1) + b)
end

function Easing.outCirc(t, b, c, d)
  t = t / d - 1
  return(c * sqrt(1 - pow(t, 2)) + b)
end

function Easing.inOutCirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return -c / 2 * (sqrt(1 - t * t) - 1) + b
  else
    t = t - 2
    return c / 2 * (sqrt(1 - t * t) + 1) + b
  end
end

function Easing.outInCirc(t, b, c, d)
  if t < d / 2 then
    return Easing.outCirc(t * 2, b, c / 2, d)
  else
    return Easing.inCirc((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.inElastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d

  if t == 1  then return b + c end

  if not p then p = d * 0.3 end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c/a)
  end

  t = t - 1

  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

-- a: amplitud
-- p: period
function Easing.outElastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d

  if t == 1 then return b + c end

  if not p then p = d * 0.3 end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c/a)
  end

  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

-- p = period
-- a = amplitud
function Easing.inOutElastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d * 2

  if t == 2 then return b + c end

  if not p then p = d * (0.3 * 1.5) end
  if not a then a = 0 end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c / a)
  end

  if t < 1 then
    t = t - 1
    return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
  else
    t = t - 1
    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
  end
end

-- a: amplitud
-- p: period
function Easing.outInElastic(t, b, c, d, a, p)
  if t < d / 2 then
    return Easing.outElastic(t * 2, b, c / 2, d, a, p)
  else
    return Easing.inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
  end
end

function Easing.inBack(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end

function Easing.outBack(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function Easing.inOutBack(t, b, c, d, s)
  if not s then s = 1.70158 end
  s = s * 1.525
  t = t / d * 2
  if t < 1 then
    return c / 2 * (t * t * ((s + 1) * t - s)) + b
  else
    t = t - 2
    return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
  end
end

function Easing.outInBack(t, b, c, d, s)
  if t < d / 2 then
    return Easing.outBack(t * 2, b, c / 2, d, s)
  else
    return Easing.inBack((t * 2) - d, b + c / 2, c / 2, d, s)
  end
end

function Easing.outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then
    return c * (7.5625 * t * t) + b
  elseif t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  else
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t * t + 0.984375) + b
  end
end

function Easing.inBounce(t, b, c, d)
  return c - Easing.outBounce(d - t, 0, c, d) + b
end

function Easing.inOutBounce(t, b, c, d)
  if t < d / 2 then
    return Easing.inBounce(t * 2, 0, c, d) * 0.5 + b
  else
    return Easing.outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
  end
end

function Easing.outInBounce(t, b, c, d)
  if t < d / 2 then
    return Easing.outBounce(t * 2, b, c / 2, d)
  else
    return Easing.inBounce((t * 2) - d, b + c / 2, c / 2, d)
  end
end

return Easing
