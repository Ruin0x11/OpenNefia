local data_table = require("internal.data_table")
local env = require("internal.env")
local binser = require("thirdparty.binser2")

if env.is_hotloading() then
   return "no_hotload"
end

return data_table:new()
