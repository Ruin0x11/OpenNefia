require("boot")

local Draw = require("api.Draw")

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

local frame = 0

function love.update(dt)
   if server then
      local msg, err = coroutine.resume(server, dt)
      if err then
         print("Error in server:\n\t" .. debug.traceback(server, err))
         print()
         error(err)
      end
   end

   if _DEBUG and profile.running then
      frame = frame + 1
      if frame % 60 == 1 then
         print(profile.report("time", 100))
      end
   end

   local msg, err = coroutine.resume(loop, dt)
   if err then
      print("Error in loop:\n\t" .. debug.traceback(loop, err))
      print()
      error(err)
   end

   fps:update(dt)

   if coroutine.status(loop) == "dead" then
      print("Finished.")
      love.event.quit()
   end
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

   internal.draw.draw_end()
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
