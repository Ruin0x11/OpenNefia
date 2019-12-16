local socket = require("socket")

local internal = {}

internal.get_timestamp = socket.gettime

return internal
