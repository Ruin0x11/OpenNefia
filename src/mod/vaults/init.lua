local Log = require("api.Log")

require("mod.vaults.data.init")
require("mod.vaults.event.init")

Log.info("Hello from %s!", _MOD_NAME)
