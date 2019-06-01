local love = require("util.automagic")()

love.graphics.getWidth = function() return 800 end
love.graphics.getHeight = function() return 600 end
love.graphics.getFont = function()
   return
      {
         getWidth = function(s) return #s * 8 end,
         getHeight = function() return 14 end,
      }
end
love.graphics.setFont = function() end
love.graphics.setColor = function() end
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
      getViewport = function() return 0, 0, 100, 100 end
   }
end
love.graphics.newFont = function()
   return {}
end
love.graphics.newImage = function()
   return {
      getWidth = function() return 100 end,
      getHeight = function() return 100 end,
      setFilter = function() end,
   }
end
love.graphics.draw = function() end
love.image.newImageData = function(fn)
   return {
      mapPixel = function() end
   }
end
love.keyboard.setKeyRepeat = function() end

return love
