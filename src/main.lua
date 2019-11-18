require("boot")

local Draw = require("api.Draw")

local env = require("internal.env")
local internal = require("internal")
local game = require("game")
local debug_server = require("util.debug_server")
local profile = require("thirdparty.profile")

local loop = nil
local draw = nil
local server = nil

local fps = require("internal.fps"):new()
fps.show_fps = true

function love.load(arg)
   love.filesystem.setIdentity("Elona_next")
   internal.draw.init()
   Draw.set_font(12)

   server = debug_server(4567)

   if arg[#arg] == "-debug" then
      _DEBUG = true
      mobdebug.start()
      mobdebug.off()
      mobdebug.coro()
   end

   loop = coroutine.create(game.loop)
   draw = coroutine.create(game.draw)
end

local halt = false
local pop_draw_layer = false
local halt_error = ""

local function stop_halt()
   love.keypressed = internal.input.keypressed

   halt = false
end

local function start_halt()
   internal.input.halt_input()
   love.keypressed = function(key, scancode, isrepeat)
      local keys = table.set {"return", "escape", "space"}
      if keys[key] then
         stop_halt()
      elseif key == "backspace" then
         pop_draw_layer = true
         stop_halt()
      end
   end

   halt = true
end

function love.update(dt)
   fps:update(dt)

   if internal.draw.needs_wait() then
      return
   end

   if server then
      local ok, err = coroutine.resume(server, dt)
      if not ok then
         print("Error in server:\n\t" .. debug.traceback(server, err))
         print()
         error(err)
      else
         local result = err
         if halt and result == "success" then
            stop_halt()
         end
      end
   end

   if halt then
      return
   end

   local ok, err = coroutine.resume(loop, dt, pop_draw_layer)
   pop_draw_layer = false
   if not ok or err ~= nil then
      print("Error in loop:\n\t" .. debug.traceback(loop, err))
      print()
      if not ok then
         -- Coroutine is dead. No choice but to throw.
         error(err)
      else
         -- We can continue executing since game.loop is still alive.
         start_halt()
         halt_error = err
      end
   end

   if coroutine.status(loop) == "dead" then
      print("Finished.")
      love.event.quit()
   end
end

function love.draw()
   if halt then
      internal.draw.draw_error(halt_error)
      return
   end

   internal.draw.draw_start()

   local going = true
   local ok, err = coroutine.resume(draw, going)
   if not ok or err then
      print("Error in draw:\n\t" .. debug.traceback(draw, err))
      print()
      if not ok then
         -- Coroutine is dead. No choice but to throw.
         error(err)
      else
         -- We can continue executing since game.loop is still alive.
         start_halt()
         halt_error = err
      end
   end

   fps:draw()

   internal.draw.draw_end()

   env.set_hotloaded_this_frame(false)
end

--
--
-- LÖVE callbacks
--
--

love.resize = internal.draw.resize

love.mousemoved = internal.input.mousemoved
love.mousepressed = internal.input.mousepressed
love.mousereleased = internal.input.mousereleased

love.keypressed = internal.input.keypressed
love.keyreleased = internal.input.keyreleased

love.textinput = internal.input.textinput
