data:add_type {
   name = "emotion_icon",
   schema = schema.Record {
      image = schema.String,
   },
}

data:edit_type(
   "core.chara",
   {
      emotion_icon = schema.Optional(schema.String),
   }
)
