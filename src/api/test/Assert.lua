local Assert = {}

function Assert.is_truthy(actual, msg)
   assert(actual, msg)
end

function Assert.is_falsy(actual, msg)
   assert(not actual, msg)
end

function Assert.eq(expected, actual)
   if expected ~= actual then
      error(("expected '%s', got '%s'"):format(expected, actual))
   end
end

function Assert.not_eq(lhs, rhs)
   if lhs == rhs then
      error(("expected '%s' ~= '%s', but both were equal"):format(lhs, rhs))
   end
end

function Assert.gt(expected, actual)
   if actual <= expected then
      error(("expected '%s' > '%s'"):format(expected, actual))
   end
end

function Assert.lt(expected, actual)
   if actual >= expected then
      error(("expected '%s' < '%s'"):format(expected, actual))
   end
end

function Assert.throws_error(f, err_match, ...)
   local ok, err = pcall(f, ...)
   if ok then
      error("expected error, but was successful")
   end
   if err_match then
      if not err:match(err_match) then
         error(("expected error to match '%s', got '%s'"):format(err_match, err))
      end
   end
end

return Assert
