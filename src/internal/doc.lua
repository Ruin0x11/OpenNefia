local fs = require("util.fs")
local paths = require("internal.paths")
local ldoc = require("thirdparty.ldoc")
local Log = require("api.Log")
local SaveFs = require("api.SaveFs")

local doc_store = require("internal.global.doc_store")

local doc = {}

local ldoc_config = nil

local function read_file(file)
   local inf = io.open(file, 'r')
   if not inf then
      return nil, "Failed to open `"..file.."` for reading"
   end

   local s = inf:read('*all')
   inf:close()

   return s
end

local function read_ldoc_config(fname)
   local chunk, err, ok
   local path = fs.join(fs.get_working_directory(), fname)
   local txt, not_found = read_file(path)
   if not_found then
      error(("ldoc config file not found: %s"):format(path))
   end
   local config = table.deepcopy(ldoc)
   if txt then
      chunk, err = load(txt,path,nil,config)
      if chunk then
         ok,err = pcall(chunk)
      end
   end
   if err then error('error loading ldoc config file '..fname..': '..err) end
   return config, not_found
end

local function get_paths(path)
   local file_path = package.searchpath(path, package.path) or path

   file_path = fs.normalize(file_path)

   local req_path = paths.convert_to_require_path(file_path)
   return file_path, req_path
end

local function copy_table(tbl, keys)
   local result = {}
   for _, k in ipairs(keys) do
      result[k] = tbl[k]
   end
   return result
end

local function convert_ldoc_file(file)
   local base = fs.normalize(file.base)
   local filename = fs.normalize(file.filename)
   local relative = string.strip_prefix(filename, fs.get_working_directory() .. "/")
   return {
      base = base,
      filename = filename,

      relative = relative
   }
end

function doc.get_item_name(item)
   local name = item.name

   -- ldoc parses method names in classmods as "Class:func", wheras
   -- names in modules are just parsed as "func". If this is a method,
   -- use the last segments in the names hierarchy.
   if item.kind == "methods" then
      -- item.names_hierarchy = { "IChara", "set_pos" }
      local rest = table.deepcopy(item.names_hierarchy)
      table.remove(rest, 1)
      name = table.concat(rest)
   end

   return name
end

function doc.get_item_full_name(item)
   local name = doc.get_item_name(item)
   if item.kind == "methods" then
      name = string.format("%s:%s", item.mod_name, name)
   else
      name = string.format("%s.%s", item.mod_name, name)
   end
   return name
end

local function file_to_full_path(file, item, is_builtin)
   local prefix = paths.convert_to_require_path(file.relative)
   if is_builtin then
      prefix = prefix:match("%.([^.]+)$")
   end
   if item == nil then
      return prefix
   end

   local name = doc.get_item_name(item)

   return ("%s.%s"):format(prefix, name):gsub(":", ".")
end

--- Reformats a docstring such that singular line breaks are joined,
--- while preserving the wrapping of lines with a non-alphabetic first
--- character or more than one consecutive linebreak.
local function reformat_docstring(docstring)
   local res = ""

   docstring:gsub("\r\n", "")
   docstring:gsub("\n\r", "")

   local no_next_break = false
   for line in string.lines(docstring) do
      local break_line = true

      local is_blank_line = string.match(line, "^%s*$")

      if string.match(line, "^%s*[A-Za-z]") then
         break_line = false
      end

      -- Do break if enough leading whitespace is found.
      if string.match(line, "^%s%s") then
         break_line = true
         no_next_break = true
      end

      res = res .. line

      if not (res == "" and is_blank_line) then
         if break_line then
            res = res .. "\n"
         end
         if is_blank_line then
            if no_next_break then
               no_next_break = false
            else
               res = res .. "\n"
            end
         end
      end
   end

   return res
end

local function convert_ldoc_item(item, mod_name, is_builtin)
   local t = copy_table(
      item,
      {
         "args",
         "description",
         "formal_args",
         "inferred",
         "kind",
         "lineno",
         "modifiers",
         "name",
         "names_hierarchy",
         "parameter",
         "params",
         "section",
         "subparams",
         "summary",
         "tags",
         "type",
      }
   )

   -- modify fields that are not encodable by json.lua
   if t.params then
      t.params.params = {}
      for i = 1, #t.params do
         t.params.params[i] = t.params[i]
         t.params[i] = nil
      end
   end
   if t.formal_args then
      t.formal_args.args = {}
      for i = 1, #t.formal_args do
         t.formal_args.args[i] = t.formal_args[i]
         t.formal_args[i] = nil
      end
   end
   if t.modifiers then
      if t.modifiers.param then
         local remove = {}
         for k, _ in pairs(t.modifiers.param) do
            if type(k) ~= "number" then
               remove[#remove+1] = k
            end
         end
         for _, k in ipairs(remove) do
            t.modifiers.param[k] = nil
         end
      end
   end
   t.kinds = nil

   if item.file == nil then
      error(inspect(item))
   end
   t.mod_name = mod_name
   t.file = convert_ldoc_file(item.file)
   t.full_path = file_to_full_path(t.file, item, is_builtin)

   t.summary = reformat_docstring(t.summary)
   t.description = reformat_docstring(t.description)

   return t.full_path:lower(), t
end

-- Strips unnecessary info from ldoc's raw output.
local function convert_ldoc(dump, is_builtin)
   local t = copy_table(
      dump,
      {
         "description",
         "inferred",
         "kind",
         "kinds",
         "lineno",
         "mod_name",
         "modifiers",
         "name",
         "names_hierarchy",
         "package",
         "sections",
         "summary",
         "type",
      }
   )

   t.is_builtin = is_builtin
   t.items = fun.wrap(ipairs(dump.items)):map(function(i) return convert_ldoc_item(i, t.mod_name, is_builtin) end):to_map()
   t.file = convert_ldoc_file(dump.file)
   t.full_path = file_to_full_path(t.file, nil, is_builtin)
   t.last_updated = os.time()
   t.is_module = true

   t.summary = reformat_docstring(t.summary)
   t.description = reformat_docstring(t.description)

   return t
end

-- Makes the object `key` point to the documentation for the file/item
-- indicated by `alias`.
-- @tparam any key
-- @tparam {file_path=string,full_path=string} alias
local function add_alias(key, alias)
   assert(doc_store.entries[alias.file_path], alias.file_path .. inspect(table.keys(doc_store.entries)))

   alias.full_path = alias.full_path:lower()

   if type(key) == "string" then
      key = key:lower()
   end

   doc_store.aliases[key] = doc_store.aliases[key] or {}
   for _, other in ipairs(doc_store.aliases[key]) do
      if other.file_path == alias.file_path and other.full_path == alias.full_path then
         return
      end
   end

   table.insert(doc_store.aliases[key], alias)
end

local function doc_entry_for_req_path(req_path)
   local file_path = get_paths(req_path)
   return doc_store.entries[file_path], file_path
end

local function alias_api_fields(api_table, req_path)
   -- Associate functions with their corresponding documentation, so
   -- you can do things like Doc.help(Rand.rnd).
   local tbl = api_table
   if tbl.all_methods then
      tbl = tbl.all_methods
   end

   local entry, file_path = doc_entry_for_req_path(req_path)
   assert(entry)

   if tbl then
      for k, obj in pairs(tbl) do
         if type(obj) == "function" then
            local full_path = ("%s.%s"):format(req_path, k):lower()
            local item = entry.items[full_path]
            if item then
               -- This item has documentation available, so add an alias for it.
               add_alias(obj, {file_path=file_path, full_path=full_path})
            end
         end
      end
   end

   add_alias(entry.full_path, {file_path=file_path, full_path=entry.full_path})
   add_alias(api_table, {file_path=file_path, full_path=entry.full_path})
end

local function add_common_aliases(item, file_path)
   local full_path = item.full_path
   local alias = { file_path=file_path, full_path=full_path }

   add_alias(full_path, alias)

   if item.is_module then
      -- "IChara"
      add_alias(item.mod_name, alias)
   else
      -- "rnd"/"set_pos"
      add_alias(doc.get_item_name(item), alias)

      if item.type == "function" then
         if item.kind == "methods" then
            -- "IChara:set_pos"
            add_alias(item.name, alias)

            -- "IChara.set_pos"
            local name = table.concat(item.names_hierarchy, ".")
            add_alias(name, alias)
         else
            -- "Rand.rnd"
            local name = string.format("%s.%s", item.mod_name, item.name)
            add_alias(name, alias)
         end
      end
   end
end

local CONFIG_FILE = "data/ldoc.ld"

function doc.reparse(path, api_table, is_builtin)
   local file_path, req_path = get_paths(path)

   ldoc_config = ldoc_config or read_ldoc_config(CONFIG_FILE)
   local dump = ldoc.dump_file(file_path, ldoc_config)[1]

   if is_builtin then
      -- Resolve this file to the API name ("table")
      file_path = is_builtin
      req_path = is_builtin
   end

   if dump == nil then
      local warnings = require("thirdparty.ldoc.doc").Item.warnings
      Log.debug("LDoc produced no output for %s", path)
      for _, warning in ipairs(warnings) do
         Log.warn(warning)
      end
      return false
   end

   Log.info("Updating documentation for %s (%s)", req_path, path)

   local result = convert_ldoc(dump, is_builtin)

   if is_builtin then
      result.is_builtin = true
      if doc_store.entries[file_path] then
         table.merge(doc_store.entries[file_path].items, result.items)
      else
         doc_store.entries[file_path] = result
      end
   else
      doc_store.entries[file_path] = result
   end

   local seen = table.set {}
   for full_path, item in pairs(result.items) do
      if seen[full_path] then
         error(full_path)
      end
      seen[full_path] = true

      local aliases = doc_store.aliases[full_path]
      if aliases then
         for _, alias in ipairs(aliases) do
            local file = doc_store.entries[alias.file_path]
            assert(file, alias.file_path)
            assert(file.file.filename == item.file.filename, ("%s %s"):format(inspect(file.file), inspect(item.file)))
         end
      end

      add_common_aliases(item, file_path)

      if is_builtin then
         item.is_builtin = true
      end
   end

   add_common_aliases(result, file_path)

   if type(api_table) == "table" then
      alias_api_fields(api_table, req_path)
   end

   return true
end

function doc.get(path)
   local aliases, entry

   if type(path) == "string" then
      path = path:lower()
      if string.find(path, "^ext%.") then
         path = path:gsub("^ext%.", "")
      end
      local file_path = get_paths(path)
      entry = doc_store.entries[file_path]
   elseif type(path) == "table" then
      if path.__iface then
         path = path.__iface
      elseif path.__class then
         path = path.__class
      end
      entry = nil
   end

   if entry == nil then
      aliases = doc_store.aliases[path]
      if aliases and #aliases > 0 then
         if #aliases == 1 then
            local alias = aliases[1]
            local file = doc_store.entries[alias.file_path]
            assert(file)

            if alias.full_path == file.full_path:lower() then
               -- this is a module
               entry = file
            else
               -- this is an item inside the module
               entry = file.items[alias.full_path]
            end

            return {
               type = "entry",
               entry = entry
            }
         else
            return {
               type = "candidates",
               candidates = fun.iter(aliases):extract("full_path"):to_list()
            }
         end
      end
   end

   if path and aliases and aliases[1].file_path ~= path then
      return nil, ("No documentation for %s (%s)"):format(aliases[1].file_path, path)
   else
      return nil, ("No documentation for %s"):format(path)
   end
end

function doc.build_for(dir)
   for _, api in fs.iter_directory_items(dir .. "/") do
      local path = fs.join(dir, api)
      if fs.is_file(path) and fs.extension_part(path) == "lua" then
         local req_path = paths.convert_to_require_path(path)
         local success, tbl = pcall(require, path)
         if success then
            doc.reparse(req_path, tbl)
         else
            Log.debug("API require failed: %s", tbl)
         end
      elseif fs.is_directory(path) then
         doc.build_for(path)
      end
   end
end

function doc.build_all()
   doc.clear()

   doc.build_for("api")
   doc.build_for("mod")

   -- Lua stdlib
   local builtin_dir = "thirdparty/ldoc/builtin"
   for _, api in fs.iter_directory_items(builtin_dir) do
      local path = fs.join(builtin_dir, api)
      if fs.is_file(path) and fs.extension_part(path) == "lua" then
         local req_path = paths.convert_to_require_path(path)
         local api_name = fs.filename_part(path)

         -- require the original API
         local success, tbl = pcall(require, api_name)

         if success then
            doc.reparse(req_path, tbl, api_name)
         else
            Log.debug("API require failed: %s", tbl)
         end
      end
   end

   -- ext
   local ext_dir = "ext"
   for _, api in fs.iter_directory_items(ext_dir) do
      local path = fs.join(ext_dir, api)
      if fs.is_file(path) and fs.extension_part(path) == "lua" then
         local req_path = paths.convert_to_require_path(path)
         local api_name = fs.filename_part(path)

         -- require the original API
         local success, tbl = pcall(require, api_name)

         if success then
            assert(type(tbl) == "table", api_name)
            doc.reparse(req_path, tbl, api_name)
         else
            Log.debug("API require failed: %s", tbl)
         end
      end
   end
end

function doc.clear()
   doc_store.entries = {}
   doc_store.aliases = {}
   doc_store.can_load = true
end

local function doc_store_path()
   return fs.join("data", "doc")
end

function doc.save()
   local remove = {}
   for k, _ in pairs(doc_store.aliases) do
      if type(k) ~= "string" then
         remove[#remove+1] = k
      end
   end
   for _, key in ipairs(remove) do
      remove[key] = doc_store.aliases[key]
      doc_store.aliases[key] = nil
   end

   local str = SaveFs.serialize(doc_store)
   local path = doc_store_path()
   local dirs = fs.parent(path)
   fs.create_directory(dirs)

   Log.info("Saving documentation to %s.", path)
   fs.write(path, str)

   for _, key in ipairs(remove) do
      doc_store.aliases[key] = remove[key]
   end
end

function doc.load()
   local path = doc_store_path()

   if not fs.exists(path) then
      return
   end

   Log.info("Loading documentation from %s.", path)

   local str, err = fs.read(path)
   if not str then
      error(err)
   end

   table.replace_with(doc_store, SaveFs.deserialize(str))

   for p, entry in pairs(doc_store.entries) do
      local file_path, req_path = get_paths(p)
      local api_table
      if entry.is_builtin then
         print("BUILTIN", entry.mod_name)
         api_table = require(entry.mod_name)
         req_path = entry.mod_name
      else
         print("non", entry.mod_name)
         api_table = require(file_path)
      end
      alias_api_fields(api_table, req_path)
   end

   doc_store.can_load = true
end

function doc.can_load()
   -- only start loading documentation on require after there has been an
   -- attempt to load the doc store on startup.
   return doc_store.can_load
end

return doc
