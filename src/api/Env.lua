local Env = {}

function Env.version()
   return "0.0.1"
end

function Env.love_version()
   return love.getVersion()
end

function Env.os()
   return love.system.getOS()
end

return Env
