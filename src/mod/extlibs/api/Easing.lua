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

function Easing.in_quad(t, b, c, d)
  t = t / d
  return c * pow(t, 2) + b
end

function Easing.out_quad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end

function Easing.in_out_quad(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 2) + b
  else
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end
end

function Easing.out_in_quad(t, b, c, d)
  if t < d / 2 then
    return Easing.out_quad (t * 2, b, c / 2, d)
  else
    return Easing.in_quad((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.in_cubic(t, b, c, d)
  t = t / d
  return c * pow(t, 3) + b
end

function Easing.out_cubic(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 3) + 1) + b
end

function Easing.in_out_cubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * t * t * t + b
  else
    t = t - 2
    return c / 2 * (t * t * t + 2) + b
  end
end

function Easing.out_in_cubic(t, b, c, d)
  if t < d / 2 then
    return Easing.out_cubic(t * 2, b, c / 2, d)
  else
    return Easing.in_cubic((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.in_quart(t, b, c, d)
  t = t / d
  return c * pow(t, 4) + b
end

function Easing.out_quart(t, b, c, d)
  t = t / d - 1
  return -c * (pow(t, 4) - 1) + b
end

function Easing.in_out_quart(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 4) + b
  else
    t = t - 2
    return -c / 2 * (pow(t, 4) - 2) + b
  end
end

function Easing.out_in_quart(t, b, c, d)
  if t < d / 2 then
    return Easing.out_quart(t * 2, b, c / 2, d)
  else
    return Easing.in_quart((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.in_quint(t, b, c, d)
  t = t / d
  return c * pow(t, 5) + b
end

function Easing.out_quint(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 5) + 1) + b
end

function Easing.in_out_quint(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 5) + b
  else
    t = t - 2
    return c / 2 * (pow(t, 5) + 2) + b
  end
end

function Easing.out_in_quint(t, b, c, d)
  if t < d / 2 then
    return Easing.out_quint(t * 2, b, c / 2, d)
  else
    return Easing.in_quint((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.in_sine(t, b, c, d)
  return -c * cos(t / d * (pi / 2)) + c + b
end

function Easing.out_sine(t, b, c, d)
  return c * sin(t / d * (pi / 2)) + b
end

function Easing.in_out_sine(t, b, c, d)
  return -c / 2 * (cos(pi * t / d) - 1) + b
end

function Easing.out_in_sine(t, b, c, d)
  if t < d / 2 then
    return Easing.out_sine(t * 2, b, c / 2, d)
  else
    return Easing.in_sine((t * 2) -d, b + c / 2, c / 2, d)
  end
end

function Easing.in_expo(t, b, c, d)
  if t == 0 then
    return b
  else
    return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
  end
end

function Easing.out_expo(t, b, c, d)
  if t == d then
    return b + c
  else
    return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
  end
end

function Easing.in_out_expo(t, b, c, d)
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

function Easing.out_in_expo(t, b, c, d)
  if t < d / 2 then
    return Easing.out_expo(t * 2, b, c / 2, d)
  else
    return Easing.in_expo((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.in_circ(t, b, c, d)
  t = t / d
  return(-c * (sqrt(1 - pow(t, 2)) - 1) + b)
end

function Easing.out_circ(t, b, c, d)
  t = t / d - 1
  return(c * sqrt(1 - pow(t, 2)) + b)
end

function Easing.in_out_circ(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return -c / 2 * (sqrt(1 - t * t) - 1) + b
  else
    t = t - 2
    return c / 2 * (sqrt(1 - t * t) + 1) + b
  end
end

function Easing.out_in_circ(t, b, c, d)
  if t < d / 2 then
    return Easing.out_circ(t * 2, b, c / 2, d)
  else
    return Easing.in_circ((t * 2) - d, b + c / 2, c / 2, d)
  end
end

function Easing.in_elastic(t, b, c, d, a, p)
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
function Easing.out_elastic(t, b, c, d, a, p)
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
function Easing.in_out_elastic(t, b, c, d, a, p)
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
function Easing.out_in_elastic(t, b, c, d, a, p)
  if t < d / 2 then
    return Easing.out_elastic(t * 2, b, c / 2, d, a, p)
  else
    return Easing.in_elastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
  end
end

function Easing.in_back(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end

function Easing.out_back(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function Easing.in_out_back(t, b, c, d, s)
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

function Easing.out_in_back(t, b, c, d, s)
  if t < d / 2 then
    return Easing.out_back(t * 2, b, c / 2, d, s)
  else
    return Easing.in_back((t * 2) - d, b + c / 2, c / 2, d, s)
  end
end

function Easing.out_bounce(t, b, c, d)
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

function Easing.in_bounce(t, b, c, d)
  return c - Easing.out_bounce(d - t, 0, c, d) + b
end

function Easing.in_out_bounce(t, b, c, d)
  if t < d / 2 then
    return Easing.in_bounce(t * 2, 0, c, d) * 0.5 + b
  else
    return Easing.out_bounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
  end
end

function Easing.out_in_bounce(t, b, c, d)
  if t < d / 2 then
    return Easing.out_bounce(t * 2, b, c / 2, d)
  else
    return Easing.in_bounce((t * 2) - d, b + c / 2, c / 2, d)
  end
end

return Easing
