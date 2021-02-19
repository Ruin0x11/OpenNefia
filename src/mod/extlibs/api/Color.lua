-----------------------------------------------------------------------------
-- Provides support for color manipulation in HSL color space.
--
-- http://sputnik.freewisdom.org/lib/colors/
--
-- License: MIT/X
--
-- (c) 2008 Yuri Takhteyev (yuri@freewisdom.org) *
--
-- * rgb_to_hsl() implementation was contributed by Markus Fleck-Graffe.
-----------------------------------------------------------------------------

local Color = class.class("Color")

-----------------------------------------------------------------------------
-- Instantiates a new "color".
--
-- @param H              hue (0-360) _or_ an RGB string ("#930219")
-- @param S              saturation (0.0-1.0)
-- @param L              lightness (0.0-1.0)
-- @param A              alpha (0.0-1.0)
-- @return               an instance of Color
-----------------------------------------------------------------------------
function Color:init(H, S, L, A)
   if type(H) == "table" then
      local t = H
      H, S, L, A = t[1], t[2], t[3], t[4]
   end
   self.H = math.clamp(H, 0, 360)
   self.S = math.clamp(S, 0, 1)
   self.L = math.clamp(L, 0, 1)
   self.A = math.clamp(A or 1, 0, 1)
end

function Color:new_hsl(H, S, L, A)
   if type(H) == "table" then
      local t = H
      H, S, L, A = t[1], t[2], t[3], t[4]
   end
   return Color:new(H, S, L, A)
end

function Color:new_rgb(R, G, B, A)
   if type(R) == "table" then
      local t = R
      R, G, B, A = t[1], t[2], t[3], t[4]
   end
   return Color:new(Color.rgb_to_hsl(R/255, G/255, B/255, A and A/255))
end

function Color:new_rgb_float(R, G, B, A)
   if type(R) == "table" then
      local t = R
      R, G, B, A = t[1], t[2], t[3], t[4]
   end
   return Color:new(Color.rgb_to_hsl(R, G, B, A and A))
end

function Color:from_string(s)
   local H, S, L, A
   if s:sub(1,1)=="#" and s:len() == 7 then
      H, S, L, A = Color.rgb_string_to_hsl(s)
   elseif s:sub(1,1)=="#" and s:len() == 9 then
      H, S, L, A = Color.rgba_string_to_hsl(s)
   end
   error("unknown string format " .. tostring(s))
   return Color:new_float(H, S, L, A)
end

-----------------------------------------------------------------------------
-- Converts an HSL triplet to RGB
-- (see http://homepages.cwi.nl/~steven/css/hsl.html).
--
-- @param H              hue (0-360)
-- @param S              saturation (0.0-1.0)
-- @param L              lightness (0.0-1.0)
-- @return               an R, G, B and A component of RGBA
-----------------------------------------------------------------------------

function Color.hsl_to_rgb(h, s, L, a)
   h = h/360
   local m1, m2
   if L<=0.5 then
      m2 = L*(s+1)
   else
      m2 = L+s-L*s
   end
   m1 = L*2-m2

   local function _h2rgb(m1, m2, h)
      if h<0 then h = h+1 end
      if h>1 then h = h-1 end
      if h*6<1 then
         return m1+(m2-m1)*h*6
      elseif h*2<1 then
         return m2
      elseif h*3<2 then
         return m1+(m2-m1)*(2/3-h)*6
      else
         return m1
      end
   end

   return _h2rgb(m1, m2, h+1/3), _h2rgb(m1, m2, h), _h2rgb(m1, m2, h-1/3), a
end

-----------------------------------------------------------------------------
-- Converts an RGB triplet to HSL.
-- (see http://easyrgb.com)
--
-- @param r              red (0.0-1.0)
-- @param g              green (0.0-1.0)
-- @param b              blue (0.0-1.0)
-- @param a              alpha (0.0-1.0)
-- @return               corresponding H, S, L and A components
-----------------------------------------------------------------------------

function Color.rgb_to_hsl(r, g, b, a)
   --r, g, b = r/255, g/255, b/255
   local min = math.min(r, g, b)
   local max = math.max(r, g, b)
   local delta = max - min

   local h, s, l = 0, 0, ((min+max)/2)

   if l > 0 and l < 0.5 then s = delta/(max+min) end
   if l >= 0.5 and l < 1 then s = delta/(2-max-min) end

   if delta > 0 then
      if max == r and max ~= g then h = h + (g-b)/delta end
      if max == g and max ~= b then h = h + 2 + (b-r)/delta end
      if max == b and max ~= r then h = h + 4 + (r-g)/delta end
      h = h / 6;
   end

   if h < 0 then h = h + 1 end
   if h > 1 then h = h - 1 end

   return h * 360, s, l, a
end

function Color.rgb_string_to_hsl(rgb)
   assert(type(rgb) == "string" and rgb:sub(1,1)=="#" and rgb:len() == 7)
   return Color.rgb_to_hsl(tonumber(rgb:sub(2,3), 16)/255,
                           tonumber(rgb:sub(4,5), 16)/255,
                           tonumber(rgb:sub(6,7), 16)/255)
end

function Color.rgba_string_to_hsl(rgba)
   assert(type(rgba) == "string" and rgba:sub(1,1)=="#" and rgba:len() == 9)
   return Color.rgb_to_hsl(tonumber(rgba:sub(2,3), 16)/255,
                           tonumber(rgba:sub(4,5), 16)/255,
                           tonumber(rgba:sub(6,7), 16)/255,
                           tonumber(rgba:sub(8,9), 16)/255)
end

-----------------------------------------------------------------------------
-- Converts the color to an RGB string.
--
-- @return               a 6-digit RGB representation of the color prefixed
--                       with "#" (suitable for inclusion in HTML)
-----------------------------------------------------------------------------

function Color:__tostring()
   local r, g, b, a = Color.hsl_to_rgb(self.H, self.S, self.L, self.A)
   if a then
      return ("rgba(%d, %d, %d, %d)"):format(r, g, b, a)
   else
      return ("rgb(%d, %d, %d)"):format(r, g, b)
   end
end

-----------------------------------------------------------------------------
-- Creates a new color with hue different by delta.
--
-- @param delta          a delta for hue.
-- @return               a new instance of Color.
-----------------------------------------------------------------------------
function Color:hue_offset(delta)
   return Color:new((self.H + delta) % 360, self.S, self.L, self.A)
end

-----------------------------------------------------------------------------
-- Creates a complementary color.
--
-- @return               a new instance of Color
-----------------------------------------------------------------------------
function Color:complementary()
   return self:hue_offset(180)
end

-----------------------------------------------------------------------------
-- Creates two neighboring colors (by hue), offset by "angle".
--
-- @param angle          the difference in hue between this color and the
--                       neighbors
-- @return               two new instances of Color
-----------------------------------------------------------------------------
function Color:neighbors(angle)
   local angle = angle or 30
   return self:hue_offset(angle), self:hue_offset(360-angle)
end

-----------------------------------------------------------------------------
-- Creates two new colors to make a triadic color scheme.
--
-- @return               two new instances of Color
-----------------------------------------------------------------------------
function Color:triadic()
   return self:neighbors(120)
end

-----------------------------------------------------------------------------
-- Creates two new colors, offset by angle from this colors complementary.
--
-- @param angle          the difference in hue between the complementary and
--                       the returned colors
-- @return               two new instances of Color
-----------------------------------------------------------------------------
function Color:split_complementary(angle)
   return self:neighbors(180-(angle or 30))
end

-----------------------------------------------------------------------------
-- Creates a new color with saturation set to a new value.
--
-- @param saturation     the new saturation value (0.0 - 1.0)
-- @return               a new instance of Color
-----------------------------------------------------------------------------
function Color:desaturate_to(saturation)
   return Color:new(self.H, saturation, self.L, self.A)
end

-----------------------------------------------------------------------------
-- Creates a new color with saturation set to a old saturation times r.
--
-- @param r              the multiplier for the new saturation
-- @return               a new instance of Color
-----------------------------------------------------------------------------
function Color:desaturate_by(r)
   return Color:new(self.H, self.S*r, self.L, self.A)
end

-----------------------------------------------------------------------------
-- Creates a new color with lightness set to a new value.
--
-- @param lightness      the new lightness value (0.0 - 1.0)
-- @return               a new instance of Color
-----------------------------------------------------------------------------
function Color:lighten_to(lightness)
   return Color:new(self.H, self.S, lightness, self.A)
end

-----------------------------------------------------------------------------
-- Creates a new color with lightness set to a old lightness times r.
--
-- @param r              the multiplier for the new lightness
-- @return               a new instance of Color
-----------------------------------------------------------------------------
function Color:lighten_by(r)
   return Color:new(self.H, self.S, self.L*r, self.A)
end

-----------------------------------------------------------------------------
-- Creates n variations of this color using supplied function and returns
-- them as a table.
--
-- @param f              the function to create variations
-- @param n              the number of variations
-- @return               a table with n values containing the new colors
-----------------------------------------------------------------------------
function Color:variations(f, n)
   n = n or 5
   local results = {}
   for i=1,n do
	  table.insert(results, f(self, i, n))
   end
   return results
end

-----------------------------------------------------------------------------
-- Creates n tints of this color and returns them as a table
--
-- @param n              the number of tints
-- @return               a table with n values containing the new colors
-----------------------------------------------------------------------------
function Color:tints(n)
   local f = function (color, i, n)
                return color:lighten_to(color.L + (1-color.L)/n*i)
             end
   return self:variations(f, n)
end

-----------------------------------------------------------------------------
-- Creates n shades of this color and returns them as a table
--
-- @param n              the number of shades
-- @return               a table with n values containing the new colors
-----------------------------------------------------------------------------
function Color:shades(n)
   local f = function (color, i, n)
                return color:lighten_to(color.L - (color.L)/n*i)
             end
   return self:variations(f, n)
end

function Color:tint(r)
      return self:lighten_to(self.L + (1-self.L)*r)
end

function Color:shade(r)
      return self:lighten_to(self.L - self.L*r)
end

function Color:to_number()
   local R, G, B, A = Color.hsl_to_rgb(self.H, self.S, self.L, self.A)
   return math.floor(R * 255 * 16777216 + G * 255 * 65536 + B * 255 * 256 + (A or 1) * 255)
end

function Color:from_number(n)
   return Color:new_rgb(math.floor(n / 16777216) % 256, math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256)
end

function Color:to_rgb()
   local R, G, B, A = Color.hsl_to_rgb(self.H, self.S, self.L, self.A)
   return math.floor(R*255), math.floor(G*255), math.floor(B*255), math.floor((A or 1) * 255)
end

function Color:to_rgb_float()
   return Color.hsl_to_rgb(self.H, self.S, self.L, self.A)
end

function Color:to_hsl()
   return math.floor(self.H*255), math.floor(self.S*255), math.floor(self.L*255), math.floor((self.A or 1) * 255)
end

function Color:to_hsl_float()
   return self.H, self.S, self.L, self.A
end

return Color
