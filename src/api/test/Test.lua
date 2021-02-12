local Test = {}

function Test.assert_eq(expected, actual)
   if expected == actual then
      return true, nil
   else
      return false, ("expected '%s', got '%s'"):format(expected, actual)
   end
end

function Test.assert_gt(expected, actual)
   if expected > actual then
      return true, nil
   else
      return false, ("expected '%s' > '%s'"):format(expected, actual)
   end
end

function Test.assert_error(f, err_match, ...)
   local ok, err = pcall(f, ...)
   if ok then
      return false, ("expected error, but was successful")
   end
   if err_match then
      if not err:match(err_match) then
         return false, ("expected error to match '%s', got '%s'"):format(err_match, err)
      end
   end
   return true, nil
end

return Test
