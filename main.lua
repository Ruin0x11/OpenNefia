local socket = require("socket")

local Draw = require("api.Draw")
local Input = require("api.Input")

local internal = require("internal")

local keys = nil
local mouse = nil

local imgx = 0
local imgy = 0
local text = ""

function love.load()
   a_down = false
   text = ""
   image = Draw.load_image("cake.png")
   image2 = Draw.load_image("cake2.png")
   imgx = 0
   imgy = 0
   Draw.set_font("MS-Gothic.ttf", 12)
   Draw.set_color(255, 255, 255)
   internal.draw.set_background_color(0,0,0)
end

function love.update(dt)
   if down then
      imgx = love.mouse.getX()
      imgy = love.mouse.getY()
   end
end

local show_fps = true
local ms = 0
local frames = 0
local fps = ""
local last = internal.get_timestamp()
function love.draw()
   Draw.set_color(255, 255, 255)

   Draw.image(image, imgx, imgy)
   Draw.image(image2, imgx, imgy)

   Draw.text("Click and drag the cake around or use the arrow keys", 50, 50)

   Draw.text("This text is not black because of the line below", 100, 100, {255, 255, 255})
   Draw.text("This text is red", 100, 200, {255, 0, 0})

   Draw.set_color(255, 255, 255)
   Draw.text(text, 100, 230)
   Draw.text(tostring(a_down), 100, 240)

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
      Draw.text(fps, 5, 5)
   end
end

Input.set_mouse_handler {
   [1] = function(x, y, pressed, istouch)
      down = pressed
   end
}

Input.set_key_handler {
   b = function(pressed)
      local word = "released"
      if pressed then
         word = "pressed"
      end
      text = "The B key was " .. word .. "."
   end,
   a = function(pressed)
      a_down = pressed
   end
}

love.mousemoved = internal.input.mousemoved
love.mousepressed = internal.input.mousepressed
love.mousereleased = internal.input.mousereleased

love.keypressed = internal.input.keypressed
love.keyreleased = internal.input.keyreleased

function love.focus(f)
   if not f then
      print("LOST FOCUS")
   else
      print("GAINED FOCUS")
   end
end

function love.quit() end
