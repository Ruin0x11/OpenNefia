local paths = {}

local PATH_CACHE = {}

-- Converts a filepath to a uniquely identifying Lua require path.
-- Examples:
-- api/chara/IChara.lua -> api.chara.IChara
-- mod/elona/init.lua   -> mod.elona
function paths.convert_to_require_path(path)
   -- This function is gets hot since many functions call "require" in
   -- function bodies to get around circular dependencies.
   if PATH_CACHE[path] then
      return PATH_CACHE[path]
   end

   local old_path = path
   local path = path

   -- HACK: needs better normalization to prevent duplicate chunks. If
   -- this is not completely unique then two require paths could end
   -- up referring to the same file, breaking hotloading. The
   -- intention is any require path uniquely identifies a return value
   -- from `require`.
   path = string.strip_suffix(path, ".lua")
   path = string.strip_suffix(path, ".fnl")
   path = string.gsub(path, "/", ".")
   path = string.gsub(path, "\\", ".")
   path = string.strip_suffix(path, ".init")
   path = string.gsub(path, "^%.+", "")

   PATH_CACHE[old_path] = path

   return path
end

return paths
