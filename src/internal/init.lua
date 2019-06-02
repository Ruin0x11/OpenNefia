local socket = require("socket")

local internal = {}

internal.draw = require("internal.draw")
internal.input = require("internal.input")
internal.fs = require("internal.fs")
internal.mod = require("internal.mod")

internal.get_timestamp = socket.gettime

return internal
