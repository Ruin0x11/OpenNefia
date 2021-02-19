local Assert = {}

function Assert.is_true(actual, msg)
   assert(actual, msg)
end

function Assert.eq(expected, actual)
   if expected ~= actual then
      error(("expected '%s', got '%s'"):format(expected, actual))
   end
end

function Assert.gt(expected, actual)
   if expected <= actual then
      error(("expected '%s' > '%s'"):format(expected, actual))
   end
end

function Assert.lt(expected, actual)
   if expected >= actual then
      error(("expected '%s' < '%s'"):format(expected, actual))
   end
end

function Assert.error(f, err_match, ...)
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
