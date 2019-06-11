local InstancedMap = require("api.InstancedMap")

local map = {}

local this_map = nil

--
-- Singleton
--

function map.get()
   return this_map
end

function map.create(width, height)
   return this_map
end


return map
