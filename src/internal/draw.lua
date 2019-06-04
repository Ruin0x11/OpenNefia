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
   local window_mode = {
      resizable = true,
      minwidth = 800,
      minheight = 600,
      vsync = true
   }
   local success = love.window.setMode(width, height, window_mode)
   if not success then
      error("Could not initialize display.")
   end

   canvas = create_canvas(width, height)

   love.graphics.setLineStyle("rough")
   love.graphics.setDefaultFilter("nearest", "nearest", 1)
   love.graphics.setBlendMode("alpha")
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

local layers = {}
local handler = nil
local hud = nil

function draw.set_root(ui_layer)
   assert_is_an(require("api.gui.IUiLayer"), ui_layer)
   layers = {ui_layer}
   ui_layer:relayout(0, 0, draw.get_width(), draw.get_height())
   ui_layer:focus()
end

function draw.set_hud(new_hud)
   if new_hud == nil then
      hud = nil
      return
   end

   assert_is_an(require("api.gui.hud.IHud"), new_hud)
   hud = new_hud
   hud:relayout(0, 0, draw.get_width(), draw.get_height())
end

function draw.set_root_input_handler(input)
   assert_is_an(require("api.gui.IInput"), input)
   handler = input
   handler:focus()
   handler:halt_input()
end

function draw.push_layer(ui_layer)
   assert_is_an(require("api.gui.IUiLayer"), ui_layer)
   table.push(layers, ui_layer)
   ui_layer:relayout(0, 0, draw.get_width(), draw.get_height())
   ui_layer:focus()
end

function draw.pop_layer()
   table.pop(layers)
   if layers[#layers] then
      layers[#layers]:focus()
      layers[#layers]:halt_input()
   elseif handler then
      handler:focus()
      handler:halt_input()
   end
end

function draw.draw_hud()
   if hud then hud:draw() end
end

function draw.draw_layers()
   for i, layer in ipairs(layers) do
      print(i, layer)
      layer:draw()
   end
end

--
--
-- Event callbacks
--
--

function draw.resize(w, h)
   canvas = create_canvas(w, h)

   if hud then hud:relayout(0, 0, w, h) end

   for _, layer in ipairs(layers) do
      layer:relayout(0, 0, w, h)
   end

   collectgarbage()
end

--
--
-- API functions
--
--

draw.get_width = love.graphics.getWidth
draw.get_height = love.graphics.getHeight

local font_cache = setmetatable({}, { __mode = "v" })
function draw.set_font(size, kind, filename)
   local font
   kind = kind or "normal"
   filename = filename or "data/MS-Gothic.ttf"
   if not font_cache[size] then font_cache[size] = setmetatable({}, { __mode = "v" }) end
   font_cache[size][filename] = font_cache[size][filename]
      or love.graphics.newFont(filename, size, "mono")
   love.graphics.setFont(font_cache[size][filename])
end

function draw.set_color(r, g, b, a)
   if type(r) == "table" then
      love.graphics.setColor(
         (r[1] or 255) / 255,
         (r[2] or 255) / 255,
         (r[3] or 255) / 255,
         (r[4] or 255) / 255)
   else
      love.graphics.setColor(
         (r or 255) / 255,
         (g or 255) / 255,
         (b or 255) / 255,
         (a or 255) / 255)
   end
end

function draw.set_background_color(r, g, b, a)
   love.graphics.setBackgroundColor(r, g, b, a)
end

function draw.text(str, x, y, color, size)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   if size then
      draw.set_font(size)
   end
   love.graphics.print(str, x, y)
end

function draw.filled_rect(x, y, width, height, color)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.polygon("fill", x, y, x + width, y, x + width, y + height, x, y + height)
end

function draw.line_rect(x, y, width, height, color)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.polygon("line", x, y, x + width, y, x + width, y + height, x, y + height)
end

function draw.line(x1, y1, x2, y2, color)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.line(x1, y1 + 1, x2, y2 + 1)
end

function draw.text_width(str)
   return love.graphics.getFont():getWidth(str)
end

function draw.text_height(str)
   return love.graphics.getFont():getHeight()
end

local image_cache = setmetatable({}, { __mode = "v" })
function draw.load_image(filename, keycolor)
   if keycolor == nil then keycolor = {0, 0, 0} end
   if image_cache[filename] then return image_cache[filename] end
   local image_data = love.image.newImageData(filename)

   if type(keycolor) == "table" then
      -- HACK: Horrendous. This takes an obscene amount of time. The
      -- images should be preprocessed instead with libVIPS or
      -- something as a compile step...
      local function trans(x,y,r,g,b,a)
         if r == keycolor[1] and g == keycolor[2] and b == keycolor[3] then a = 0 end
         return r,g,b,a
      end

      mobdebug.scope(function()
            image_data:mapPixel(trans)
      end)
   end

   image_cache[filename] = love.graphics.newImage(image_data)
   return image_cache[filename]
end

function draw.load_shader(filename)
   local function read_all(file)
      local f = assert(io.open(file, "rb"))
      local content = f:read("*all")
      f:close()
      return content
   end

   return love.graphics.newShader(read_all(filename))
end

function draw.use_shader(filename)
   love.graphics.setShader(filename)
end

function draw.image(image, x, y, width, height, color, centered, rotation)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   local sx = 1
   local sy = 1
   if width then
      sx = width / image:getWidth()
   end
   if height then
      sy = height / image:getHeight()
   end
   local ox, oy
   if centered then
      ox = (image:getWidth()) / 2
      oy = (image:getHeight()) / 2
   end
   return love.graphics.draw(image, x, y, rotation or 0, sx, sy, ox, oy)
end

function draw.image_region(image, quad, x, y, width, height, color, centered, rotation)
   if color then
      draw.set_color(color[1], color[2], color[3], color[4])
   end
   local sx = 1
   local sy = 1
   local _, _, qw, qh = quad:getViewport()
   if width then
      sx = width / qw
   end
   if height then
      sy = height / qh
   end
   local ox, oy
   if centered then
      ox = (width or qw) / 2
      oy = (width or qh) / 2
   end
   return love.graphics.draw(image, quad, x, y, 0, sx, sy, ox, oy)
end

function draw.image_stretched(image, x, y, tx, ty, color, rotation)
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

function draw.image_region_stretched(image, quad, x, y, tx, ty, color, rotation)
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

function draw.debug_pos(x, y)
   draw.set_color(255, 0, 0)
   draw.set_font(11)
   draw.text(string.format("%d/%d", x, y), x, y)
   draw.filled_rect(x - 4, y - 4, 8, 8)
   draw.set_color(255, 255, 255)
end

function draw.debug_rect(x, y, w, h, centered)
   if centered then
      x = x - w / 2
      y = y - h / 2
   end
   local p = {
      {x, y},
      {x+w, y},
      {x, y+h},
      {x+w, y+h}
   }
   for _, pos in ipairs(p) do
      draw.debug_pos(pos[1], pos[2])
   end
   draw.line_rect(x, y, w, h)
end

return draw
