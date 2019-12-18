--- @module Shiori

local Sstp = require("mod.sstp.api.Sstp")

local Shiori = {}

--- @tparam string id
--- @tparam[opt] {{string,string}...} params
--- @treturn table
function Shiori.get(id, params)
   params = params or {}
   table.insert(params, 1, {"ID", id})
   params[#params+1] = {"SecurityLevel", "local"}
   return Sstp.send_raw("GET", "SHIORI/2.0", params)
end

--- @tparam string id
--- @tparam[opt] {{string,string}...} params
--- @treturn table
function Shiori.notify(id, params)
   params = params or {}
   table.insert(params, 1, {"ID", id})
   params[#params+1] = {"SecurityLevel", "local"}
   return Sstp.send_raw("NOTIFY", "SHIORI/2.0", params)
end

return Shiori
