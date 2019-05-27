local socket = require("socket")

local internal = {}

internal.draw = require("internal.draw")
internal.input = require("internal.input")

internal.get_timestamp = socket.gettime

return internal
