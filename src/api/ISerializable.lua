local ISerializable = class.interface("ISerializable", {
                                         serialize_nbt = "function",
                                         deserialize_nbt = "function",
})

return ISerializable
