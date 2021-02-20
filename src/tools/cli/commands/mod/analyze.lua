local mod = require("internal.mod")
local fs = require("util.fs")
local startup = require("game.startup")
local Event = require("api.Event")
local field = require("game.field")
local data = require("internal.data")

local function print_tree(mods, stream)
   local load_order = mod.calculate_load_order(mods)

   local mod_to_types = {}
   local adding_mod_to_type_to_count = {}
   local type_to_total_count = {}

   local max_len = 0

   for _, ty, entries in data:iter() do
      local mod_id = ty:match("^(.*)%.")
      mod_to_types[mod_id] = mod_to_types[mod_id] or {}
      table.insert(mod_to_types[mod_id], ty)
      adding_mod_to_type_to_count[ty] = {}
      type_to_total_count[ty] = 0
      max_len = math.max(string.len(ty), max_len)

      for _, entry in entries:iter() do
         local adding_mod_id = entry._id:match("^(.*)%.")
         adding_mod_to_type_to_count[adding_mod_id] = adding_mod_to_type_to_count[adding_mod_id] or {}
         adding_mod_to_type_to_count[adding_mod_id][ty] = (adding_mod_to_type_to_count[adding_mod_id][ty] or 0) + 1
         type_to_total_count[ty] = type_to_total_count[ty] + 1
      end
   end

   local function print_counts_added(counts_added)
      local order = table.keys(counts_added)
      table.sort(order)
      for _, type_id in ipairs(order) do
         local count = counts_added[type_id]
         stream:write(("  - %s: %s%d entr%s\n"):format(type_id, string.rep(" ", max_len - string.len(type_id)), count, count == 1 and "y" or "ies"))
      end
   end

   for _, m in ipairs(load_order) do
      local mod_id = m.id
      local manifest = assert(mod.load_manifest(m.manifest_path))
      stream:write(("+ %s (%s)\n"):format(mod_id, manifest.version))
      local found = false
      if mod_to_types[mod_id] then
         found = true
         local types_string = table.concat(mod_to_types[mod_id], ", ")
         stream:write(("  * %d types added: %s\n"):format(#mod_to_types[mod_id], types_string))
      end
      local counts_added = adding_mod_to_type_to_count[mod_id]
      if counts_added then
         print_counts_added(counts_added)
      end
   end

   stream:write("\n")
   stream:write("+++ Total +++\n")
   print_counts_added(type_to_total_count)
end

return function(args)
   if not fs.exists(fs.get_save_directory()) then
      fs.create_directory(fs.get_save_directory())
   end

   local mods = mod.scan_mod_dir()
   startup.run_all(mods)

   Event.trigger("base.on_startup")
   field:init_global_data()

   print_tree(mods, io.stdout)
end
