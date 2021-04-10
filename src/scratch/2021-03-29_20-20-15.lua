local god_to_categories = {}
local category_to_not_gods = {}
local category_to_not_gods_nonprecious = {}

for _, item in data["base.item"]:iter() do
   if item.gods then
      for _, god in pairs(item.gods) do
         god_to_categories[god] = god_to_categories[god] or {}
         for _, category in pairs(item.categories) do
            god_to_categories[god][category] = (god_to_categories[god][category] or 0) + 1
         end
      end
   end
end

local gods = table.keys(god_to_categories)

for _, item in data["base.item"]:iter() do
   for _, category in pairs(item.categories) do
      category_to_not_gods[category] = category_to_not_gods[category] or {}
      category_to_not_gods_nonprecious[category] = category_to_not_gods_nonprecious[category] or {}
      local item_gods = table.set(item.gods or {})
      for _, god in pairs(gods) do
         category_to_not_gods[category][god] = category_to_not_gods[category][god] or 0
         category_to_not_gods_nonprecious[category][god] = category_to_not_gods_nonprecious[category][god] or 0
         if not item_gods[god] then
            category_to_not_gods[category][god] = category_to_not_gods[category][god] + 1
            if not item.is_precious then
               category_to_not_gods_nonprecious[category][god] = category_to_not_gods_nonprecious[category][god] + 1
            end
         end
      end
   end
end

print(inspect(god_to_categories))
print()
print(inspect(category_to_not_gods))
print()
print(inspect(category_to_not_gods_nonprecious))

local final = {}
for category, gods in pairs(category_to_not_gods_nonprecious) do
   for god, count in pairs(gods) do
      if count == 0 then
         final[god] = final[god] or {}
         table.insert(final[god], category)
      end
   end
end

print(inspect(final))

local final2 = {}

for _, item in data["base.item"]:iter() do
   if item.gods then
      for _, god in pairs(item.gods) do
         local found = true
         for _, category in pairs(item.categories) do
            if table.set(final[god])[category] then
               found = false
               break
            end
         end
         if found then
            final2[god] = final2[god] or {}
            table.insert(final2[god], item._id)
         end
      end
   end
end

print(inspect(final2))

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
