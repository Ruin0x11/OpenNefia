-- binpack.lua
--
-- Based on SharpFont BinPacker.cs (c) 2015 Michael Popoloski, licensed under MIT
-- https://github.com/MikePopoloski/SharpFont/blob/master/SharpFont/Internal/BinPacker.cs
--
-- Uses MAXRECTS method developed by Jukka Jylänki http://clb.demon.fi/files/RectangleBinPack.pdf
--
-- Does not support rotating rectangles for better fitting.
-- Does not support dynamic spritesheet sizes; you must pick a size up-front
--
-- Ported to Lua by leafi. Licensed under MIT, as that is how the original source was licensed.
-- !!! binpack_instance:insert(w,h) returns nil instead of empty rectangle if placement failed, unlike original code !!!
--

-- API EXAMPLE:
--[[
-- binpack_example.lua
local binpack_new = require('binpack')
local bp = binpack_new(2048, 2048)

local rect1 = bp:insert(32, 64)
--  (rect1 has .x, .y, .w, .h, :clone(), :contains(rect), .right, .bottom)
print('rect1:', rect1) -- rect1: {x=0,y=0,w=32,h=64}

local rect2 = bp:insert(100, 101)
print('rect2:', rect2) -- rect2: {x=0,y=64,w=100,h=101}

print('\n20 250x200 rects: '); for i = 1,20 do print(bp:insert(250, 200)) end

print('\nClearing; changing binpack instance to 1024x1024')
bp:clear(1024, 1024)  -- you MUST provide w,h again
print('10 370x430 rects in 1024x1024:'); for i = 1,10 do print(bp:insert(370, 430)) end

-- you can call binpack_new(w, h) again if you want 2 binpackers simultaneously. it's not an issue.
--]]

--
-- (Another potentially interesting rect packer to port would be one of the Java ports
--  of stb_rect_pack.h. stb_rect_pack is public-domain - but is written in C - but surely
--  a Java conversion would solve most of the problems already.
--  stb_rect_pack uses Skyline Bottom-Left.)
--

--
-- Rectangle implementation... don't be afraid to delete & make binpacker use your rectangle type instead!
--
-- (api: fields: .x, .y, .w, .h, read-only: .right, .bottom, func: :clone(), :contains(another_rect))
--

local rect_mt = {}
function rect_mt.__eq(a, b)
  return a.x == b.x and a.y == b.y and a.w == b.w and a.h == b.h
end
function rect_mt.__index(rect, key)
  return rect_mt[key] or (rect_mt['get_' .. key] and rect_mt['get_' .. key](rect) or nil)
end
function rect_mt.__newindex(rect, key, value)
  if rect_mt['get_' .. key] then error(key .. ' property/field alias is read-only. change fields instead') end
  return rawset(rect, key, value)
end
function rect_mt.__tostring(self)
  return '{x=' .. self.x .. ',y=' .. self.y .. ',w=' .. self.w .. ',h=' .. self.h .. '}'
end
function rect_mt.clone(self)
  local nr = {x=self.x, y=self.y, w=self.w, h=self.h}
  setmetatable(nr, rect_mt)
  return nr
end
function rect_mt.contains(self, r)
  return r.x >= self.x and r.y >= self.y and r.right <= self.right and r.bottom <= self.bottom
end
function rect_mt.empty(self)
  return self.w == 0 or self.h == 0
end
function rect_mt.get_right(self)
  return self.x + self.w
end
function rect_mt.get_bottom(self)
  return self.y + self.h
end
function rect_mt.get_width(self) return self.w end
function rect_mt.get_height(self) return self.h end
function rect_mt.get_left(self) return self.x end
function rect_mt.get_top(self) return self.y end

local function new_rect(x, y, w, h)
  local rect = {x=x or 0, y=y or 0, w=w or 0, h=h or 0}
  setmetatable(rect, rect_mt)
  return rect
end

--
-- BinPacker class
--

-- Lua 5.3 introduces real 64-bit integers. This probably isn't needed - who has spritesheets with lengths this big?! - but...
local binpacker_insert_prelude = (math.maxinteger and math.tointeger) and (function(self,w,h)
  -- a.k.a. Lua 5.3+ path; we have the integer type
  -- coerce to integers, just in case...
  w = math.tointeger(math.ceil(w))
  h = math.tointeger(math.ceil(h))
  if not w or not h then error('binpack:insert(w,h) had either w or h not coercable to integer (Lua 5.3+ path)') end
  return w, h, math.maxinteger
end) or (function(self,w,h)
  -- a.k.a. Lua <= 5.2 path
  -- best-effort coerce to integers. you'll be fine if your 'integers' already fit within like 52 bits(?) or something.
  w = math.ceil(w)
  h = math.ceil(h)
  return w, h, math.huge
end)

local binpacker_funcs = {
  clear = function(self, w, h)
    self.freelist = {new_rect(0, 0, math.floor(w), math.floor(h))}
  end,
  insert = function(self, w, h)
    local maxvalue
    w, h, maxvalue = binpacker_insert_prelude(self, w, h)

    local bestNode = new_rect()
    local bestShortFit = maxvalue
    local bestLongFit = maxvalue

    local count = #self.freelist
    for i=1,count do
      -- try to place the rect
      local rect = self.freelist[i]

      if not (rect.w < w or rect.h < h) then
        local leftoverX = math.abs(rect.w - w)
        local leftoverY = math.abs(rect.h - h)
        local shortFit = math.min(leftoverX, leftoverY)
        local longFit = math.max(leftoverX, leftoverY)

        if shortFit < bestShortFit or (shortFit == bestShortFit and longFit < bestLongFit) then
          bestNode.x = rect.x
          bestNode.y = rect.y
          bestNode.w = w
          bestNode.h = h
          bestShortFit = shortFit
          bestLongFit = longFit
        end
      end -- end if
    end -- end for

    -- !!! returns 'nil' for failed placement unlike empty rectangle in original C# code
    if bestNode.h == 0 then return nil end

    -- split out free areas into smaller ones
    local i = 1
    while i <= count do
      if self:_splitFreeNode(self.freelist[i], bestNode) then
        table.remove(self.freelist, i)
        i = i - 1
        count = count - 1
      end
      i = i + 1
    end

    -- prune the freelist
    i = 1
    while i <= #self.freelist do
      local j = i + 1
      while j <= #self.freelist do
        local idata = self.freelist[i]
        local jdata = self.freelist[j]
        if jdata:contains(idata) then
          table.remove(self.freelist, i)
          i = i - 1
          break
        end

        if idata:contains(jdata) then
          table.remove(self.freelist, j)
          j = j - 1
        end
        j = j + 1
      end
      i = i + 1
    end

    -- !!! returns 'nil' for failed placement unlike empty rectangle in original C# code
    return bestNode.w > 0 and bestNode or nil
  end,
  _splitFreeNode = function(self, freeNode, usedNode)
    -- test if the rects even intersect
    local insideX = usedNode.x < freeNode.right and usedNode.right > freeNode.x
    local insideY = usedNode.y < freeNode.bottom and usedNode.bottom > freeNode.y
    if not insideX or not insideY then return false end

    if insideX then
      -- new node at the top side of the used node
      if usedNode.y > freeNode.y and usedNode.y < freeNode.bottom then
        local newNode = freeNode:clone()
        newNode.h = usedNode.y - newNode.y
        self.freelist[#self.freelist+1] = newNode
      end

      -- new node at the bottom side of the used node
      if usedNode.bottom < freeNode.bottom then
        local newNode = freeNode:clone()
        newNode.y = usedNode.bottom
        newNode.h = freeNode.bottom - usedNode.bottom
        self.freelist[#self.freelist+1] = newNode
      end
    end

    if insideY then
      -- new node at the left side of the used node
      if usedNode.x > freeNode.x and usedNode.x < freeNode.right then
        local newNode = freeNode:clone()
        newNode.w = usedNode.x - newNode.x
        self.freelist[#self.freelist+1] = newNode
      end

      -- new node at the right side of the used node
      if usedNode.right < freeNode.right then
        local newNode = freeNode:clone()
        newNode.x = usedNode.right
        newNode.w = freeNode.right - usedNode.right
        self.freelist[#self.freelist+1] = newNode
      end
    end

    return true
  end
}

local binpacker_mt = {__index=binpacker_funcs}

local function binpacker_new(self, w, h)
  if not w or not h then error('must provide w,h to binpack new') end
  local binpacker = {freelist={new_rect(0, 0, math.floor(w), math.floor(h))}}
  setmetatable(binpacker, binpacker_mt)
  return binpacker
end

return { new = binpacker_new }
