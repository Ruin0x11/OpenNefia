return class.interface("ISerializable",
                       {
                          serialize = "function",
                          deserialize = "function",
                          __serial_id = "string",
                          __serial_type = { type = "string", optional = true } -- "immediate", "deferred"
                       })
