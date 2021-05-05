local config = require("internal.config")
local draw_callbacks = require("internal.draw_callbacks")
local env = require("internal.env")
local fs = require("util.fs")
local WidgetContainer = require("api.gui.WidgetContainer")

if env.is_hotloading() then
   return "no_hotload"
end

local draw = {}

local WIDTH = 800
local HEIGHT = 600

local canvas = nil
local canvas_last = nil
local canvas_final = nil
local error_canvas = nil
local layers = {}
local sorted_layers = {}
local global_layers = {}
local sorted_global_layers = {}
local handler = nil
local gamma_correct = nil
local lx, ly, lw, lh
local use_logical = false

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

local function set_window_mode(width, height, window_mode)
   window_mode = window_mode or {}
   window_mode.minwidth = 800
   window_mode.minheight = 600
   window_mode.vsync = true
   window_mode.resizable = true

   local success = love.window.setMode(width, height, window_mode)
   if not success then
      error("Could not initialize display.")
   end

   draw.resize(width, height)
end

function draw.get_width()
   local actual_width = love.graphics.getWidth()
   if use_logical then
      return math.clamp(lw, WIDTH, math.max(actual_width - lx, WIDTH))
   end
   return actual_width
end

function draw.get_height()
   local actual_height = love.graphics.getHeight()
   if use_logical then
      return math.clamp(lh, HEIGHT, math.max(actual_height - ly, HEIGHT))
   end
   return actual_height
end

function draw.get_actual_width()
   return love.graphics.getWidth()
end

function draw.get_actual_height()
   return love.graphics.getHeight()
end

function draw.get_logical_viewport()
   return 0, 0, draw.get_width(), draw.get_height()
end

function draw.set_logical_viewport(x, y, w, h)
   local actual_width = love.graphics.getWidth()
   local actual_height = love.graphics.getHeight()

   lx = x or 0
   ly = y or 0
   lw = math.max(w or actual_width, WIDTH)
   lh = math.max(h or actual_height, HEIGHT)

   if use_logical then
      draw.resize(actual_width, actual_height)
   end
end

function draw.set_logical_viewport_enabled(enabled)
   use_logical = not not enabled
   draw.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

function draw.is_logical_viewport_enabled()
   return not not use_logical
end

function draw.init()
   love.window.setTitle("OpenNefia")
   set_window_mode(WIDTH, HEIGHT)

   love.graphics.setLineStyle("rough")
   love.graphics.setDefaultFilter("nearest", "nearest", 1)
   love.graphics.setBlendMode("alpha")

   gamma_correct = love.graphics.newShader("mod/base/graphic/shader/gamma.frag.glsl")

   lx = 0
   ly = 0
   lw = draw.get_actual_width()
   lh = draw.get_actual_height()
end

function draw.draw_inner_start()
   love.graphics.setCanvas(canvas)
   love.graphics.clear()
end

function draw.draw_inner_end()
   love.graphics.setCanvas()

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.setBlendMode("alpha", "premultiplied")

   love.graphics.setCanvas(canvas_last)
   love.graphics.draw(canvas)
   love.graphics.setCanvas()

   love.graphics.setBlendMode("alpha")
end

function draw.draw_inner_canvas()
   local x = 0
   local y = 0
   if use_logical then
      x = lx
      y = ly
   end

   love.graphics.draw(canvas, x, y)
end

function draw.draw_outer_start(c)
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.setCanvas(c or canvas_final)
   love.graphics.clear()
end

function draw.draw_outer_end(c)
   love.graphics.setCanvas()

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.setBlendMode("alpha", "premultiplied")

   love.graphics.setShader(gamma_correct)
   love.graphics.draw(c or canvas_final)
   love.graphics.setShader()

   love.graphics.setBlendMode("alpha")
end

local function do_sort(t, extra)
   local r = {}
   for i, entry in ipairs(t) do
      r[i] = entry
   end
   if extra then
      r[#r+1] = extra
   end
   table.sort(r, function(a, b) return a.priority < b.priority end)
   return fun.iter(r):extract("layer"):to_list()
end

local function sort_layers()
   sorted_layers = do_sort(layers)
end

function draw.set_root(ui_layer, priority)
   priority = priority or 0
   class.assert_is_an(require("api.gui.IUiLayer"), ui_layer)
   layers = {{layer=ui_layer, priority=priority}}
   sort_layers()
   ui_layer:relayout(draw.get_logical_viewport())
   ui_layer:focus()
end

function draw.set_root_input_handler(input)
   class.assert_is_an(require("api.gui.IInput"), input)
   handler = input
   handler:focus()
   handler:halt_input()
end

function draw.push_layer(ui_layer, priority)
   class.assert_is_an(require("api.gui.IUiLayer"), ui_layer)
   priority = priority or ui_layer:default_z_order()
   ui_layer:relayout(draw.get_logical_viewport())
   ui_layer:focus()
   table.insert(layers, {layer=ui_layer, priority=priority})
   sort_layers()
end

function draw.pop_layer()
   layers[#layers] = nil
   sort_layers()
   if layers[#layers] then
      layers[#layers].layer:focus()
      layers[#layers].layer:halt_input()
   elseif handler then
      handler:focus()
      handler:halt_input()
   end
end

function draw.get_layers()
   return layers
end

function draw.get_layer(i)
   if i <= 0 then
      return layers[#layers+i]
   else
      return layers[i]
   end
end

function draw.get_current_layer()
   return layers[#layers]
end

function draw.layer_count()
   return #layers
end

function draw.get_max_z_order()
   local max = 0
   for _, v in ipairs(layers) do
      max = math.max(max, v.priority)
   end
   return max
end

function draw.is_layer_active(layer)
   for _, pair in ipairs(layers) do
      if pair.layer == layer then
         return true
      end
   end
   return false
end

local coroutines = {}

local function hotload_layer(layer)
   if layer.on_hotload_layer then
      layer:on_hotload_layer()
   end
   layer:relayout(draw.get_logical_viewport())

   layer:bind_keys(layer:make_keymap())
end

function draw.draw_layers()
   if env.hotloaded_this_frame() then
      for _, entry in ipairs(layers) do
         hotload_layer(entry.layer)
      end
   end

   for _, layer in ipairs(sorted_layers) do
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

local CANVAS_PRIORITY = 100000
local canvas_ = { layer = "canvas", priority = CANVAS_PRIORITY }
local function sort_global_layers()
   sorted_global_layers = do_sort(global_layers, canvas_)
end
sort_global_layers()

function draw.push_global_layer(layer, priority)
   class.assert_is_an(require("api.gui.ILayer"), layer)
   priority = priority or layer:default_z_order()
   layer:relayout(draw.get_logical_viewport())
   table.insert(global_layers, {layer=layer, priority=priority})
   sort_global_layers()
end

function draw.pop_global_layer()
   global_layers[#global_layers] = nil
   sort_global_layers()
end

function draw.update_global_layers(dt)
   for _, layer in ipairs(sorted_global_layers) do
      if layer ~= "canvas" then
         layer:update(dt)
      end
   end
end

function draw.draw_global_layers()
   if env.hotloaded_this_frame() then
      for _, entry in ipairs(global_layers) do
         if entry.layer ~= "canvas" then
            hotload_layer(entry.layer)
         end
      end
   end

   for _, layer in ipairs(sorted_global_layers) do
      if layer == "canvas" then
         draw.draw_inner_canvas()
      else
         layer:draw()
      end
   end
end

local global_widgets = WidgetContainer:new()

function draw.add_global_widget(widget, tag, opts)
   global_widgets:add(widget, tag, opts)
   global_widgets:relayout(0, 0, draw.get_actual_width(), draw.get_actual_height())
end

function draw.remove_global_widget(tag)
   global_widgets:remove(tag)
end

function draw.global_widget(tag)
   return global_widgets:get(tag)
end

function draw.draw_global_widgets()
   global_widgets:draw()
end

function draw.update_global_widgets(dt)
   global_widgets:update(dt, nil)
end

local global_draw_callbacks = draw_callbacks:new()

function draw.add_global_draw_callback(cb, tag)
   global_draw_callbacks:add(cb, tag)
end

function draw.remove_global_draw_callback(tag)
   global_draw_callbacks:remove(tag)
end

function draw.draw_global_draw_callbacks()
   global_draw_callbacks:draw(0, 0)
end

function draw.update_global_draw_callbacks(dt)
   global_draw_callbacks:update(dt)
end

function draw.wait_global_draw_callbacks()
   global_draw_callbacks:wait()
end

function draw.has_active_global_draw_callbacks(include_bg_cbs)
   return global_draw_callbacks:has_more(include_bg_cbs)
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
   return coords:get_tiled_width(draw.get_width())
end

function draw.get_tiled_height()
   return coords:get_tiled_height(draw.get_height() - (72 + 16))
end

function draw.with_canvas(other_canvas, f, ...)
   local prev_canvas = love.graphics.getCanvas()

   love.graphics.setCanvas(other_canvas)
   love.graphics.setBlendMode("alpha")

   local ok, err = xpcall(f, debug.traceback, ...)

   love.graphics.setCanvas(prev_canvas)

   if not ok then
      error(err)
   end
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

local FALLBACK_FONT = fs.join("data/font", "kochi-gothic-subst.ttf")
local default_font = FALLBACK_FONT

function draw.set_default_font(font)
   local path = fs.join("data/font", font)
   assert(fs.exists(path), "Font file " .. path .. " does not exist")
   default_font = default_font
end

local font_cache = setmetatable({}, { __mode = "v" })
function draw.set_font(size, style, filename)
   if type(size) == "table" then
      filename = size.filename
      style = size.style
      size = size.size
   end
   assert(type(size) == "number")
   style = style or "normal"
   filename = filename or default_font
   if not font_cache[size] then font_cache[size] = setmetatable({}, { __mode = "v" }) end
   font_cache[size][filename] = font_cache[size][filename]
      or love.graphics.newFont(filename, size, "mono")
   love.graphics.setFont(font_cache[size][filename])
end

-- Function called when an error is caught by the main loop.
function draw.draw_error(err)
   if handler then
      handler:halt_input()
   end
   love.graphics.setScissor()
   draw.draw_outer_start(error_canvas)
   love.graphics.draw(canvas_final)
   love.graphics.setColor(0, 0, 0, 128/256)
   love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

   local x = 70
   local y = 70

   local _, lines = love.graphics.getFont():getWrap(err, love.graphics.getWidth() - x)

   lines[#lines+1] = ""
   lines[#lines+1] = ""
   lines[#lines+1] = "Strike [Enter] or send code to continue, [Backspace] to exit current layer."

   draw.set_font(14)
   love.graphics.origin()
   love.graphics.setColor(1, 1, 1, 1)

   for _, line in ipairs(lines) do
      love.graphics.print(line, x, y)
      y = y + love.graphics.getFont():getHeight()
   end

   draw.draw_outer_end(error_canvas)
end

function draw.draw_low_power()
   draw.draw_outer_start(error_canvas)
   love.graphics.draw(canvas_final)
   love.graphics.setColor(0, 0, 0, 128/256)
   love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
   draw.draw_outer_end(error_canvas)
end

function draw.set_fullscreen(kind, width, height)
   if not width or not height then
      local w, h = love.window.getMode()
      width = w
      height = h
   end

   local mode = {}
   if kind == "windowed" then
      mode.fullscreen = false
   elseif kind == "exclusive" then
      mode.fullscreen = true
      mode.fullscreentype = "exclusive"
   elseif kind == "desktop" then
      mode.fullscreen = true
      mode.fullscreentype = "desktop"
   else
      error(("Invalid fullscreen type '%s'"):format(kind))
   end

   set_window_mode(width, height, mode)
end

function draw.copy_to_canvas()
   return love.graphics.newImage(canvas_last:newImageData())
end

function draw.reload_window_mode()
   local new_w, new_h = config.base.screen_resolution:match("(.+)x(.+)")
   local mode = config.base.screen_mode
   draw.set_fullscreen(mode, new_w, new_h)
end

--
--
-- Event callbacks
--
--

function draw.resize(actual_width, actual_height)
   local width, height
   if use_logical then
      width = draw.get_width()
      height = draw.get_height()
   else
      width = actual_width
      height = actual_height
   end

   canvas = create_canvas(width, height)
   canvas_last = create_canvas(width, height)

   error_canvas = create_canvas(actual_width, actual_height)
   canvas_final = create_canvas(actual_width, actual_height)

   for _, entry in ipairs(layers) do
      entry.layer:relayout(0, 0, width, height)
   end

   global_widgets:relayout(0, 0, actual_width, actual_height)

   require("api.Gui").update_screen()

   collectgarbage()
end

return draw
