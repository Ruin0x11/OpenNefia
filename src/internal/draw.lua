local env = require("internal.env")
local fs = require("util.fs")

if env.is_hotloading() then
   return "no_hotload"
end

local draw = {}

local width = 800
local height = 600

local canvas = nil
local error_canvas = nil
local layers = {}
local handler = nil
local gamma_correct = nil

--
--
-- Internal engine functions
--
--


local function create_canvas(w, h)
   local canvas = love.graphics.newCanvas(w, h)

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
   error_canvas = create_canvas(width, height)

   love.graphics.setLineStyle("rough")
   love.graphics.setDefaultFilter("nearest", "nearest", 1)
   love.graphics.setBlendMode("alpha")

   gamma_correct = love.graphics.newShader("graphic/shader/gamma.frag.glsl")
end

function draw.draw_start(c)
   love.graphics.setCanvas(c or canvas)
   love.graphics.clear()
end

function draw.draw_end(c)
   love.graphics.setCanvas()

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.setBlendMode("alpha", "premultiplied")

   love.graphics.setShader(gamma_correct)
   love.graphics.draw(c or canvas)
   love.graphics.setShader()

   love.graphics.setBlendMode("alpha")
end

function draw.set_root(ui_layer)
   class.assert_is_an(require("api.gui.IUiLayer"), ui_layer)
   layers = {ui_layer}
   ui_layer:relayout(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
   ui_layer:focus()
end

function draw.set_root_input_handler(input)
   class.assert_is_an(require("api.gui.IInput"), input)
   handler = input
   handler:focus()
   handler:halt_input()
end

function draw.push_layer(ui_layer)
   class.assert_is_an(require("api.gui.IUiLayer"), ui_layer)
   table.insert(layers, ui_layer)
   ui_layer:relayout(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
   ui_layer:focus()
end

function draw.pop_layer()
   layers[#layers] = nil
   if layers[#layers] then
      layers[#layers]:focus()
      layers[#layers]:halt_input()
   elseif handler then
      handler:focus()
      handler:halt_input()
   end
end

function draw.get_layer(i)
   return layers[i]
end

function draw.get_current_layer(i)
   return layers[#layers - (i or 1) + i]
end

function draw.layer_count()
   return #layers
end

local coroutines = {}

function draw.update_layers_below(dt)
   for i, layer in ipairs(layers) do
      if i < #layers then
         layer:update(dt)
      end
   end
end

function draw.draw_layers()
   if env.hotloaded_this_frame() then
      for _, layer in ipairs(layers) do
         if layer.on_hotload_layer then
            layer:on_hotload_layer()
         end
         layer:relayout(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
      end
   end

   for i, layer in ipairs(layers) do
      layer:draw()
   end

   local dead = {}
   for i, entry in ipairs(coroutines) do
      local ok, err = coroutine.resume(entry.thread)
      if not ok then
         print("Error in draw coroutine: " .. err)
         dead[#dead+1] = i
      end

      if coroutine.status(entry.thread) == "dead" then
         dead[#dead+1] = i
      end

      if entry.wait then
         break
      end
   end

   table.remove_indices(coroutines, dead)
end

function draw.needs_wait()
   for _, v in ipairs(coroutines) do
      if v.wait then
         return true
      end
   end

   return false
end

function draw.run(cb, state, wait)
   assert(type(cb) == "function")

   local f = function()
      local s = state
      while true do
         s = cb(s)
         if s == nil then
            break
         end
         coroutine.yield()
      end
   end

   local co = coroutine.create(f)

   coroutines[#coroutines+1] = {
      thread = co,
      wait = wait
   }

   if wait == true then
      -- yield out of the update thread and into the draw thread,
      -- which will prevent the update thread from running until all
      -- coroutines with wait set are finished
      coroutine.yield()
   end
end

local coords = nil

function draw.get_coords()
   return coords
end

function draw.set_coords(c)
   coords = c
end

function draw.get_tiled_width()
   return coords:get_tiled_width(love.graphics.getWidth())
end

function draw.get_tiled_height()
   return coords:get_tiled_height(love.graphics.getHeight() - (72 + 16))
end

function draw.with_canvas(other_canvas, f)
   love.graphics.setCanvas(other_canvas)
   love.graphics.setBlendMode("alpha")

   f()

   love.graphics.setCanvas(canvas)
end

local image_cache = setmetatable({}, { __mode = "v" })
function draw.load_image(filename)
   if image_cache[filename] then return image_cache[filename] end
   local image_data = love.image.newImageData(filename)

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

-- local default_font = "MS-Gothic.ttf"
local default_font = "kochi-gothic-subst.ttf"

local font_cache = setmetatable({}, { __mode = "v" })
function draw.set_font(size, style, filename)
   if type(size) == "table" then
      filename = size.filename
      style = size.style
      size = size.size
   end
   assert(type(size) == "number")
   style = style or "normal"
   filename = filename or fs.join("data/font", default_font)
   if not font_cache[size] then font_cache[size] = setmetatable({}, { __mode = "v" }) end
   font_cache[size][filename] = font_cache[size][filename]
      or love.graphics.newFont(filename, size, "mono")
   love.graphics.setFont(font_cache[size][filename])
end

-- Function called when an error is caught by the main loop.
function draw.draw_error(err)
   draw.draw_start(error_canvas)
   love.graphics.draw(canvas)
   love.graphics.setColor(0, 0, 0, 128/256)
   love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

   err = err .. "\n\nStrike [Enter] or send code to continue, [Backspace] to exit current layer."

   local pos = 70
   draw.set_font(14)
   love.graphics.origin()
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.print(err, pos, pos)

   draw.draw_end(error_canvas)
end

--
--
-- Event callbacks
--
--

function draw.resize(w, h)
   canvas = create_canvas(w, h)
   error_canvas = create_canvas(w, h)

   for _, layer in ipairs(layers) do
      layer:relayout(0, 0, w, h)
   end

   require("api.Gui").update_screen()

   collectgarbage()
end

return draw
