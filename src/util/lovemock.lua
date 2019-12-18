local fs = require("util.fs")
local love = require("thirdparty.automagic")()

local function check_path(path)
   if type(path) == "string" then
      assert(fs.is_file(path), "File does not exist: " .. path)
   end
end

love.graphics.getWidth = function() return 800 end
love.graphics.getHeight = function() return 600 end
love.graphics.getFont = function()
   return
      {
         getWidth = function(self, s) return #s * 8 end,
         getHeight = function() return 14 end,
         getWrap = function(text, width) return text, width end,
      }
end
love.graphics.setFont = function() end
love.graphics.setColor = function() end
love.graphics.setCanvas = function() end
love.graphics.setBlendMode = function() end
love.graphics.line = function() end
love.graphics.polygon = function() end
love.graphics.print = function() end
love.graphics.newSpriteBatch = function()
   return {
      clear = function() end,
      add = function() end,
      flush = function() end,
   }
end
love.graphics.newQuad = function()
   return {
      getViewport = function() return 0, 0, 48, 48 end
   }
end
love.graphics.newCanvas = function()
   return {
      newImageData = function() return {} end,
      release = function() end
   }
end
love.graphics.newFont = function(path)
   check_path(path)
   return {}
end
love.graphics.newImage = function(path)
   check_path(path)
   return {
      getWidth = function() return 48 end,
      getHeight = function() return 48 end,
      setFilter = function() end,
      release = function() end,
      typeOf = function(self, ty) return ty == "Image" end
   }
end
love.graphics.newShader = function()
   return {}
end
love.graphics.draw = function() end
love.image.newImageData = function(path)
   check_path(path)
   return {
      mapPixel = function() end,
      getPixel = function() return 1, 0, 0 end,
      getWidth = function() return 48 end,
      getHeight = function() return 48 end,
      release = function() end,
   }
end
love.audio.setDistanceModel = function() end
love.audio.setPosition= function() end
love.audio.newSource = function(path)
   check_path(path)
   return {
      play = function() end,
      stop = function() end,
      setLooping = function() end,
      setPosition = function() end,
      setRelative = function() end,
      setAttenuationDistances = function() end,
      getChannelCount = function() return 1 end,
   }
end
love.audio.play = function() end
love.keyboard.setKeyRepeat = function() end
love.keyboard.setTextInput = function() end
love.data.compress = function(_, _, obj) return obj end
love.data.decompress = function(_, _, str) return str end
love.timer.sleep = function() end

love.getVersion = function() return "lovemock" end

love.on_hotload = table.replace_with

return love
