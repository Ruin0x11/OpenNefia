local final = {}

for _, item in data["base.item"]:iter() do
   if type(item.gods) == "table" then
      for _, god in data["elona.god"]:iter() do
         if table.set(item.gods)[god._id] then
            local cats = table.set(god.offerings)
            local found = true
            for _, cat in ipairs(item.categories) do
               if cats[cat] then
                  found = false
                  break
               end
            end
            if found then
               final[#final+1] = {
                  god = god._id,
                  item = item._id
               }
            end
         end
      end
   end
end

print(inspect(final))

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
