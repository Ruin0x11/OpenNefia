data:add_type {
   name = "emotion_icon",
   schema = schema.Record {
      image = schema.String,
   },
}

data:extend_type(
   "base.chara",
   {
      emotion_icon = schema.Optional(schema.String),
   }
)

data:extend_type(
   "base.status_ailment",
   {
      emotion_icon = schema.Optional(schema.String),
   }
)
