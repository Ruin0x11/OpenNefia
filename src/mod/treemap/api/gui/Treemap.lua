local IUiElement = require("api.gui.IUiElement")
local TreemapCell = require("mod.treemap.api.gui.TreemapCell")
local Color = require("mod.elona_sys.api.Color")

local Treemap = class.class("Treemap", IUiElement)

function Treemap:init(t, depth)
   self.sizes = Treemap.calc_sizes(t, depth)
   self.depth = depth
end

local COLORS = {
   number = {150, 100, 100},
   string = {100, 150, 100},
   ["function"] = {150, 100, 150},
   boolean = {100, 100, 150},
   userdata = {150, 150, 100},
}

local BLACKLIST = table.set {
   "__class",
   "__memoized",
   "location",
   "_parent"
}

function Treemap.calc_sizes(t, depth)
   local sizes = {}
   local MAX = 250
   for k, v in pairs(t) do
      if not BLACKLIST[k] then
         local size
         local color
         local child
         local label = tostring(k)
         local value_label
         local ty = type(v)
         if ty == "table" then
            size = table.count(v)
            color = Color.hsv_to_rgb(25, (size) % 255 + 100 % 255, 100)
            if depth > 0 then
               child = Treemap:new(v, depth - 1)
            end
         else
            value_label = inspect(v)
            color = COLORS[ty] or {100, 100, 100}
            size = 1
         end
         sizes[#sizes+1] = {
            size = size,
            value = v,
            cell = TreemapCell:new(label, value_label, color, child),
         }
         if #sizes > MAX then
            break
         end
      end
   end
   return sizes
end

function Treemap.recalculate(x, y, width, height, sizes, depth)
   if #sizes <= 1 then
      local size = sizes[1]
      if size then
         size.cell:relayout(x, y, width, height)
      end
      return
   end

   local half = fun.iter(sizes):extract("size"):sum() / 2
   local total = 0

   local left = {}
   local right = {}
   local left_total = 0
   local right_total = 0

   for i, size in ipairs(sizes) do
      if total <= half and i < #sizes then
         left[#left+1] = size
         left_total = left_total + size.size
      else
         right[#right+1] = size
         right_total = right_total + size.size
      end
      total = total + size.size
   end

   local ratio
   if left_total + right_total > 0.0 then
      ratio = left_total / (left_total + right_total)
   else
      ratio = 0.5
   end

   local lx, ly, lw, lh
   local rx, ry, rw, rh
   local is_horizontal = width > height
   local pad = 0

   if is_horizontal then
      lw = math.ceil((width - pad) * ratio)
      rw = width - pad - lw
      lh = height
      rh = height
      lx = x
      ly = y
      rx = x + lw + pad
      ry = y
   else
      if total == 0 then
         lw = 0
         lh = 0
         rw = 0
         rh = 0
         lx = x
         ly = y
         rx = x
         ry = y + pad
      else
         lw = width
         lh = math.ceil((height - pad) * ratio)
         rw = width
         rh = height - pad - lh
         lx = x
         ly = y
         rx = x
         ry = y + lh + pad
      end
   end

   Treemap.recalculate(lx, ly, lw, lh, left, depth + 1)
   Treemap.recalculate(rx, ry, rw, rh, right, depth + 1)
end

function Treemap:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   Treemap.recalculate(self.x, self.y, self.width, self.height, self.sizes, 0)
end

function Treemap:draw()
   for _, size in ipairs(self.sizes) do
      size.cell:draw()
      if size.child then
         size.child:draw()
      end
   end
end

function Treemap:update(dt)
   for _, size in ipairs(self.sizes) do
      size.cell:update(dt)
      if size.child then
         size.child:update(dt)
      end
   end
end

return Treemap
