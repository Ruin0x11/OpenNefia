local lfs = require("lfs")

assert = require("luassert") -- from luarocks

test = require("thirdparty.gambiarra")
ok = nil
spy = nil
eq = nil

require("boot")

function run_tests(path)
   for file in lfs.dir(path) do
      if file ~= "." and file ~= ".." then
         local f = path..'/'..file
         local attr = lfs.attributes(f)
         assert (type(attr) == "table")
         if attr.mode == "directory" then
            run_tests(f)
         else
            if f ~= "./test/init.lua" then
               print("\t " .. f)
               local chunk, err = loadfile(f)
               if not chunk or err then
                  error(err)
               end
               setfenv(chunk, _G)
               chunk()
               print()
            end
         end
      end
   end
end

run_tests("./test")
