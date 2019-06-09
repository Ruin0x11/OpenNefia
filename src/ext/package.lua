function package.try_require(path)
   local success, obj = pcall(function() return require(path) end)
   if success then
      return obj, ""
   end

   local err = obj
   return nil, err
end
