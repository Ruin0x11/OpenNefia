local Plot = {}

function Plot.make_datasets_dwim(...)
   local x = select(1, ...)
   if type(x) ~= "table" then
      return {}
   end
   if type(x[1]) == "table" and x[1].x and x[1].y then
      return x
   end

   local datasets = {}
   local max = select("#", ...)
   local i = 1
   print(max)
   while i < max do
      local x = select(i, ...)
      local y = select(i+1, ...)
      local opts = select(i+2, ...)

      local xlen = 100
      local stop = false
      if tostring(x) == "<generator>" then
         x = x:take(xlen):to_list()
         xlen = #x
         print(i, max)
         if i == max - 2 then
            -- don't look at luafun iterator state/index
            stop = true
         end
      end
      if tostring(y) == "<generator>" then
         y = y:take(xlen):to_list()
         print(i, max)
         if i == max - 3 then
            -- don't look at luafun iterator state/index
            stop = true
         end
      elseif type(y) == "function" then
         y = fun.range(xlen):map(y):to_list()
      end

      if x and y then
         datasets[#datasets+1] = { x = x, y = y }
      elseif x and not y then
         datasets[#datasets+1] = { x = fun.range(#x):to_list(), y = x }
      end

      if stop then
         break
      end

      i = i + 3
   end

   return datasets
end

function Plot.dataset_to_csv(dataset)
   local csv = { "x,y\n" }
   for i = 1, #dataset.x do
      csv[#csv+1] = ("%s,%s\n"):format(dataset.x[i], dataset.y[i])
   end
   return table.concat(csv)
end

return Plot
