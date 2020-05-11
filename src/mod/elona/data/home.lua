data:add_type {
   name = "home",
   schema = schema.Record {
      map = schema.Optional(schema.String),
      on_generate = schema.Optional(schema.Function),
   }
}
