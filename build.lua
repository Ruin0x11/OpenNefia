package.path = package.path .. ";.\\lib\\lua-vips\\?.lua;.\\src\\?.lua"
package.cpath = package.cpath .. ";.\\lib\\luafilesystem\\lfs.dll"

local fs = require("util.fs")
local preprocess = require("tools/preprocess")

-- preprocess("deps\\elona", "src\\mod\\elona")

assert(fs.copy_directory("deps\\elona\\map", "src\\mod\\elona\\data"))
