local category_to_items = {}
for _, item in data["base.item"]:iter() do
   if not item.is_precious then
      for _, category in pairs(item.categories or {}) do
         category_to_items[category] = category_to_items[category] or {}
         table.insert(category_to_items[category], item)
      end
   end
end

local final = {}

for _, god in data["elona.god"]:iter() do
   for _, category in ipairs(god.offerings) do
      for _, item in ipairs(category_to_items[category]) do
         if not table.set(item.gods or {})[god._id] then
            final[god._id] = final[god._id] or {}
            table.insert(final[god._id], item._id)
         end
      end
   end
end

print(inspect(final))

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
