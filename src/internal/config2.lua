local config_store = require("internal.config_store")
local env = require("internal.env")

if env.is_hotloading() then
   return "no_hotload"
end

return config_store.proxy()
