local data = require("internal.data")

data:add_multi(
   "base.config_option",
   {
      {
         _id = "music",

         type = "boolean",
         default = true
      },
      {
         _id = "screen_sync",

         type = "integer",
         default = 6
      },
      {
         _id = "auto_turn_speed",

         type = "enum",
         choices = { "normal", "high", "highest" },
         default = "normal"
      },
      {
         _id = "language",

         type = "data_id",
         data_type = "base.language",
         default = "base.english"
      },
   }
)
