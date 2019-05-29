package.path = package.path .. ";./thirdparty/?.lua"

local socket = require("socket")

local Draw = require("api.Draw")

local internal = require("internal")
local game = require("game")

require("boot")

local loop = nil
local draw = nil

local fps = require("util.fps"):new()
fps.show_fps = true

function love.load(arg)
   internal.draw.init()
   Draw.set_font(12)

   if arg[#arg] == "-debug" then
      _DEBUG = true
      require("mobdebug").start()
      require("mobdebug").off()
      require("mobdebug").coro()
   end

   loop = coroutine.create(game.loop)
   draw = coroutine.create(game.draw)
end

function love.update(dt)
   local msg, err = coroutine.resume(loop, dt)
   if err then
      print("Error in loop: " .. debug.traceback(loop, err))
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
      print("Error in draw: " .. debug.traceback(draw, err))
      print()
      error(err)
   end

   fps:draw()

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
