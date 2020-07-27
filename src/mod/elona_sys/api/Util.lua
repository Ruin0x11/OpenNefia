local Sha1 = require("mod.extlibs.api.Sha1")

local Util = {}

function Util.string_to_integer(str)
   local hash_chunks = {Sha1.sha1(str)} -- list of ints
   return fun.iter(hash_chunks):foldl(fun.op.add, 0)
end

return Util
