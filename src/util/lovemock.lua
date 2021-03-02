local fs = require("util.fs")
local love = require("thirdparty.automagic")()

local function check_path(path)
   if type(path) == "string" then
      -- assert(fs.is_file(path), "File does not exist: " .. path)
   end
end

love.graphics.getWidth = function() return 800 end
love.graphics.getHeight = function() return 600 end
love.graphics.getFont = function()
   return
      {
         getWidth = function(self, s) return #s * 8 end,
         getHeight = function() return 14 end,
         getWrap = function(text, width) return width, {text} end,
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
love.graphics.newQuad = function(x, y, w, h, tw, th)
   return {
      x = x,
      y = y,
      w = w,
      h = h,
      tw = tw,
      th = th,
      getViewport = function(self) return self.x, self.y, self.w, self.h end,
      setViewport = function(self, x, y, w, h)
         self.x = x
         self.y = y
         self.w = w
         self.h = h
      end,
      release = function() end
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
love.graphics.newImageData = function(path)
   check_path(path)
   return {}
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
      setVolume = function() end,
   }
end
love.audio.play = function() end
love.keyboard.setKeyRepeat = function() end
love.keyboard.setTextInput = function() end
love.data.compress = function(_, _, obj)
   local zlib = require("zlib")
   return zlib.deflate()(obj, "full")
end
love.data.decompress = function(_, _, str)
   local zlib = require("zlib")
   return zlib.inflate()(str)
end
love.timer.sleep = function() end
love.system.getOS = function() return "lovemock" end
love.filesystem.setRequirePath = function() end
love.filesystem.load = function(path)
   if fs.is_absolute(path) then
      return loadfile(path)
   end
   return loadfile(fs.join(fs.get_working_directory(), path))
end
love.filesystem.newFile = function(filepath)
   return {
      open = function(self, mode)
         self._inner = assert(io.open(filepath, mode .. "b"))
      end,
      read = function(self, count)
         count = count or "*a"
         return self._inner:read(count)
      end,
      close = function(self)
         self._inner:close()
      end,
      seek = function(self, kind)
         return self._inner:seek(kind)
      end
   }
end
love.graphics.newText = function()
   return {
      set = function() end
   }
end
love.window.getFullscreenModes = function()
   return {
      { width = 800, height = 600 }
   }
end
love.window.setMode = function() return true end
love.window.getMode = function() return 800, 600, { fullscreen = true, fullscreentype = "desktop" } end
love.graphics.clear = function() end

love.math.colorFromBytes = function(r, g, b, a)
   return r / 255, g / 255, b / 255, (a or 255) / 255
end

love.getVersion = function() return "lovemock" end

love.on_hotload = table.replace_with

return love
