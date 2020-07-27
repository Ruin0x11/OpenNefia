local Test = {}

function Test.assert_eq(expected, actual)
   if expected == actual then
      return true, nil
   else
      return false, ("expected '%s', got '%s'"):format(expected, actual)
   end
end

return Test
