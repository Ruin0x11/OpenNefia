local lfs = require("lfs")

test = require("thirdparty.gambiarra")
ok = nil
spy = nil
eq = nil
t = require("test.test_helper")

require("boot")

t.mock_map()

local stopwatch = require("util.stopwatch")

function run_tests(path)
   local sw = stopwatch:new()

   for file in lfs.dir(path) do
      if file ~= "." and file ~= ".." then
         local f = path..'/'..file
         local attr = lfs.attributes(f)
         assert (type(attr) == "table")
         if attr.mode == "directory" then
            run_tests(f)
         else
            print("\n=========\n= SUITE = " .. f .. "\n=========")
            local chunk, err = loadfile(f)
            if not chunk or err then
               error(err)
            end
            setfenv(chunk, _G)

            sw:measure()
            chunk()

            print()
            sw:p("time")
         end
      end
   end
end

function run_all_tests()
   local total = stopwatch:new()

   total:measure()
   run_tests("./test/tests")
   print()
   total:p("TOTAL")
end

run_all_tests()
