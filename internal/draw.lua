local draw = {}

local width = 800
local height = 600

local canvas = nil

--
--
-- Internal engine functions
--
--

local function create_canvas(w, h)
   canvas = love.graphics.newCanvas(w, h)

   love.graphics.setCanvas(canvas)

   love.graphics.clear()
   love.graphics.setBlendMode("alpha")

   love.graphics.setCanvas()

   return canvas
end

function draw.init()
   love.window.setTitle("Elona_next")
   local success = love.window.setMode(width, height, {})
   if not success then
      error("Could not initialize display.")
   end

   canvas = create_canvas(width, height)
end

function draw.draw()
   love.graphics.setCanvas(canvas)
   love.graphics.clear()
end

function draw.draw_end()
   love.graphics.setCanvas()

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.setBlendMode("alpha", "premultiplied")

   love.graphics.draw(canvas)

   love.graphics.setBlendMode("alpha")
end

local root = nil
function draw.set_root(drawable)
   root = drawable
end

--
--
-- Event callbacks
--
--

function draw.resize(w, h)
   canvas = create_canvas(w, h)

   if root and root.relayout then
      root:relayout()
   end
end

--
--
-- API functions
--
--

draw.get_width = love.graphics.getWidth
draw.get_height = love.graphics.getHeight

local font_cache = setmetatable({}, { __mode = "v" })
function draw.set_font(size, filename)
   local font
   filename = filename or "data/MS-Gothic.ttf"
   if not font_cache[size] then font_cache[size] = {} end
   font_cache[size][filename] = font_cache[size][filename]
      or love.graphics.newFont(filename, size, "mono")
   love.graphics.setFont(font_cache[size][filename])
end

function draw.set_color(r, g, b, a)
   love.graphics.setColor(r / 255, g / 255, b / 255, (a or 255) / 255)
end

function draw.set_background_color(r, g, b, a)
   love.graphics.setBackgroundColor(r, g, b, a)
end

function draw.text(str, x, y, color)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.print(str, x, y)
end

function draw.filled_rect(x, y, width, height, color)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.polygon("fill", x, y, x + width, y, x + width, y + height, x, y + height)
end

function draw.line(x1, y1, x2, y2, color)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.line(x1, y1, x2, y2)
end

function draw.text_width(str)
   return love.graphics.getFont():getWidth(str)
end

function draw.text_height(str)
   return love.graphics.getFont():getHeight()
end

local image_cache = setmetatable({}, { __mode = "v" })
function draw.load_image(filename, keycolor)
   if not keycolor then keycolor = {0, 0, 0} end
   if image_cache[filename] then return image_cache[filename] end
   local image_data = love.image.newImageData(filename)

   local function trans(x,y,r,g,b,a)
      if r == keycolor[1] and g == keycolor[2] and b == keycolor[3] then a = 0 end
      return r,g,b,a
   end

   mobdebug.scope(function()
         image_data:mapPixel(trans)
   end)

   image_cache[filename] = love.graphics.newImage(image_data)
   return image_cache[filename]
end

function draw.image(image, x, y, width, height, color)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   local sx = 1
   local sy = 1
   if width and height then
      sx = width / image:getWidth()
      sy = height / image:getHeight()
   end
   return love.graphics.draw(image, x, y, 0, sx, sy)
end

function draw.image_region(image, quad, x, y, width, height, color)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   local sx = 1
   local sy = 1
   local _, _, qw, qh = quad:getViewport()
   if width and height then
      sx = width / qw
      sy = height / qh
   end
   return love.graphics.draw(image, quad, x, y, 0, sx, sy)
end

function draw.image_stretched(image, x, y, tx, ty, color)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   local sx = 1
   local sy = 1
   if tx and ty then
      sx = (tx - x) / image:getWidth()
      sy = (ty - y) / image:getHeight()
   end
   return love.graphics.draw(image, x, y, 0, sx, sy)
end

function draw.image_region_stretched(image, quad, x, y, tx, ty, color)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   local sx = 1
   local sy = 1
   local _, _, qw, qh = quad:getViewport()
   if tx and ty then
      sx = (tx - x) / qw
      sy = (ty - y) / qh
   end
   return love.graphics.draw(image, quad, x, y, 0, sx, sy)
end


return draw
