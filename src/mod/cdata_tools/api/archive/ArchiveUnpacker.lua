local Fs = require("api.Fs")
local Compress = require("api.Compress")
local struct = require("mod.extlibs.api.struct")
local StringIO = require("mod.extlibs.api.StringIO")

--- This module is for unpacking archive files with custom data.
---
--- For example, ".eum", ".ooitem" and ".oonpc" use this format.
---
--- The archive format consists of a 40-byte file name followed by a 10-byte
--- file size and the file's content, compressed with zlib.
local ArchiveUnpacker = {}

local function fsize (file)
   local current = file:seek()      -- get current position
   local size = file:seek("end")    -- get file size
   file:seek("set", current)        -- restore position
   return size
end

function ArchiveUnpacker.unpack_stream(inp)
   local result = {}

   local size = fsize(inp)

   while true do
      local filename = struct.unpack("s", inp:read(40)):gsub("\0", "")
      local entry_size = tonumber(struct.unpack("c10", inp:read(10):gsub("\0", "")))
      if entry_size == 0 then
         break
      end

      local deflated = inp:read(entry_size - 50)
      local file_content = Compress.decompress("string", "gzip", deflated)
      result[filename] = file_content

      if inp:seek() >= size then
         break
      end
   end

   inp:close()

   return result
end

function ArchiveUnpacker.unpack_string(str)
   local stream = StringIO.open(str)
   return ArchiveUnpacker.unpack_stream(stream)
end

function ArchiveUnpacker.unpack_file(filepath)
   local file = assert(Fs.open(filepath, "rb"))
   return ArchiveUnpacker.unpack_stream(file)
end

-- function ArchiveUnpacker.unpack_map(file, subfile)
--    if subfile then
--       file = file .. "/" .. subfile
--    end

--    print(file)
--    local inp = assert(io.open(file, "rb"))
--    local size = fsize(inp)
--    local header = inp:read(1024)
--    local lines = ArchiveUnpacker.split(header, "\r\n")

--    local outdir = ArchiveUnpacker.basename(file)
--    os.execute("mkdir -p \"" .. outdir .. "\"")

--    while true do
--       local filename = struct.unpack("c12", inp:read(12):gsub("\0", ""))
--       local entry_size = tonumber(struct.unpack("c12", inp:read(12):gsub("\0", "")))
--       if entry_size == 0 then
--          break
--       end

--       local outfile = outdir .. "/" .. filename
--       local outp = assert(io.open(outfile, "wb"))
--       outp:write(inp:read(entry_size - 12 * 2))
--       outp:close()

--       if inp:seek() >= size then
--          break
--       end
--    end

--    return {
--       username = lines[1],
--       userdesc = lines[2],
--       thing = lines[3],
--       thing2 = lines[4],
--       usermsg = lines[5],
--       userrelation = lines[6]
--    }
-- end

return ArchiveUnpacker
