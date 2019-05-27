local socket = require("socket")

local Draw = require("api.Draw")

local internal = require("internal")
local game = require("game")

local loop = nil

function love.load()
   internal.draw.init()
   Draw.set_font("MS-Gothic.ttf", 12)
   loop = coroutine.create(game.loop)
end

function love.update(dt)
end

local show_fps = true
local ms = 0
local frames = 0
local fps = ""
local last = internal.get_timestamp()

function love.draw()
   internal.draw.draw()

   local msg, err = coroutine.resume(loop)
   if err then
      error(err)
   end

   if show_fps then
      if ms >= 1000 then
         fps = string.format("FPS: %02.2f", frames / (ms / 1000))
         frames = 0
         ms = 0
         last = internal.get_timestamp()
      end
      frames = frames + 1
      local now = internal.get_timestamp()
      ms = ms + (now - last) * 1000
      last = now
      Draw.text(fps, 5, Draw.get_height() - 12 - 5)
   end

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
