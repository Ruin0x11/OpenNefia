local Env = require("api.Env")

return function()
   if Env.os() == "Windows" then
      os.execute("%programfiles%\\LOVE\\love.exe --console .")
   else
      os.execute("love .")
   end
end
