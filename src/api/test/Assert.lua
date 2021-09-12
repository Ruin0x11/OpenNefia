local Diff = require("api.test.Diff")
local ansicolors = require("thirdparty.ansicolors")

local Assert = {}

function Assert.is_truthy(actual, msg)
   if not actual then
      error(("expected truthy, got '%s'"):format(actual), 2)
   end
   return actual
end

function Assert.is_falsy(actual, msg)
   if actual then
      error(("expected falsy, got '%s'"):format(actual), 2)
   end
end

function Assert.eq(expected, actual)
   if expected ~= actual then
      error(("expected '%s', got '%s'"):format(expected, actual), 2)
   end
end

function Assert.not_eq(lhs, rhs)
   if lhs == rhs then
      error(("expected '%s' ~= '%s', but both were equal"):format(lhs, rhs), 2)
   end
end

local MAX_INSPECT_LENGTH = 10000
local MAX_INSPECT_IDS = 1

local function error_diff(lhs, rhs, message)
   local inspect_args = { max_length = MAX_INSPECT_LENGTH, max_ids = MAX_INSPECT_IDS }
   local lhs_insp = inspect(lhs, inspect_args)
   local rhs_insp = inspect(rhs, inspect_args)
   local diff = Diff.diff(lhs_insp, rhs_insp)
   Diff.cleanup_semantic(diff)

   local function format_line(line)
      if line[1] == Diff.DIFF_INSERT then
         return ansicolors(("%%{green}+ %s%%{reset}\n"):format(line[2]))
      elseif line[1] == Diff.DIFF_DELETE then
         return ansicolors(("%%{red}- %s%%{reset}\n"):format(line[2]))
      else
         return ("  %s\n"):format(line[2])
      end
   end

   local output = fun.iter(diff)
      :map(format_line)
      :foldl(fun.op.concat, "\n")

   error(message .. ": \n" .. output, 3)
end

function Assert.same(lhs, rhs)
   if type(lhs) == 'table' or type(rhs) == 'table' then
      if type(lhs) == 'table' and type(rhs) == 'table' then
         local result = table.deepcompare(lhs, rhs, true)
         if not result then
            error_diff(lhs, rhs, "Expected both arguments to be the same, but they were different")
         end
      else
         error_diff(lhs, rhs, "Expected both arguments to be the same, but they were different")
      end
   else
      Assert.eq(lhs, rhs)
   end
end

function Assert.subset(subset, superset)
   local need = table.set(subset)
   local have = table.set(superset)
   for k, _ in pairs(have) do
      need[k] = nil
   end
   local remain = table.count(need)
   if remain > 0 then
      error_diff(subset, superset, ("Expected subset, but %d items were not found (%s)"):format(remain, inspect(table.keys(need))))
   end
end

function Assert.gt(expected, actual)
   if actual <= expected then
      error(("expected '%s' > '%s'"):format(expected, actual), 2)
   end
end

function Assert.lt(expected, actual)
   if actual >= expected then
      error(("expected '%s' < '%s'"):format(expected, actual), 2)
   end
end

function Assert.matches(match, str)
   if not str:match(match) then
      error(("expected string to match '%s', got '%s'"):format(match, str), 2)
   end
end

function Assert.no_matches(match, str)
   if str:match(match) then
      error(("expected string to not match '%s', got '%s'"):format(match, str), 2)
   end
end

function Assert.throws_error(f, err_match, ...)
   local ok, err = xpcall(f, debug.traceback, ...)
   if ok then
      error("expected error, but was successful", 2)
   end
   if err_match then
      local first_line = string.split(tostring(err))[1]
      if not first_line:match(err_match) then
         error(("expected error to match:\n\t'%s'\ngot:\n\t'%s'"):format(err_match, err), 2)
      end
   end
end

function Assert.fail(message, ...)
   error(message:format(...))
end

return Assert
