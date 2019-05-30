package.path = package.path .. ";./thirdparty/?.lua"

require("boot")

local Draw = require("api.Draw")

local internal = require("internal")
local game = require("game")
local debug_server = require("util.debug_server")

local loop = nil
local draw = nil
local server = nil

local fps = require("util.fps"):new()
fps.show_fps = true

local mx = 0
local my = 0

function love.load(arg)
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

   internal.input.set_mouse_handler {
      moved = function(x, y)
         mx = x
         my = y
      end
   }
end

function love.update(dt)
   if server then
      local msg, err = coroutine.resume(server, dt)
      if err then
         print("Error in server:\n\t" .. debug.traceback(server, err))
         print()
         error(err)
      end
   end

   local msg, err = coroutine.resume(loop, dt)
   if err then
      print("Error in loop:\n\t" .. debug.traceback(loop, err))
      print()
      error(err)
   end

   fps:update(dt)
end

function love.draw()
   internal.draw.draw()

   local going = true
   local msg, err = coroutine.resume(draw, going)
   if err then
      print("Error in draw:\n\t" .. debug.traceback(draw, err))
      print()
      error(err)
   end

   fps:draw()

   Draw.text(string.format("%d, %d", mx, my), 5, Draw.get_height() - Draw.text_height() * 2- 5)

   internal.draw.draw_end()
end

--
--
-- LOVE callbacks
--
--

love.resize = internal.draw.resize

love.mousemoved = internal.input.mousemoved
love.mousepressed = internal.input.mousepressed
love.mousereleased = internal.input.mousereleased

love.keypressed = internal.input.keypressed
love.keyreleased = internal.input.keyreleased
