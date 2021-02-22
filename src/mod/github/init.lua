require("mod.github.data.init")

data:add_multi(
   "base.config_option",
   {
      { _id = "enabled", type = "boolean", default = false },
   }
)
