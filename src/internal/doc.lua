local fs = require("util.fs")
local paths = require("internal.paths")
local ldoc = require("thirdparty.ldoc")
local internal = require("internal.init")
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

local last_updated_time = 0
function doc.last_updated_time()
   return last_updated_time
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
   if item.mod_name == "global" then
      -- "ipairs" instead of "global.ipairs"
      return name
   end

   if item.kind == "methods" then
      name = string.format("%s:%s", item.mod_name, name)
   else
      name = string.format("%s.%s", item.mod_name, name)
   end
   return name
end

local function file_to_full_path(file, item, is_builtin)
   local prefix = paths.convert_to_require_path(file.relative)

   -- capitalize mod name, since on Windows path is always lowercase
   prefix = prefix:gsub("%.([a-z]+)$",
                        function(s)
                           if s == item.mod_name:lower() then
                              return "." .. item.mod_name
                           else
                              return "." .. s
                           end
                        end)

   prefix = prefix:gsub("^ext%.", "")

   if is_builtin then
      prefix = prefix:match("%.([^.]+)$")
   end
   if item.is_module then
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

local function copy_table(tbl, keys)
   local result = {}
   for _, k in ipairs(keys) do
      result[k] = tbl[k]
   end
   return result
end

local function convert_ldoc_item(item, mod_name, is_builtin)
   local t = copy_table(
      item,
      {
         "args",
         "description",
         "formal_args",
         "inferred",
         "is_undocumented",
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

   t.mod_name = mod_name
   t.file = convert_ldoc_file(item.file)
   t.full_path = file_to_full_path(t.file, t, is_builtin)

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
         "is_undocumented",
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

   t.is_module = true
   t.is_builtin = is_builtin
   t.items = fun.wrap(ipairs(dump.items)):map(function(i) return convert_ldoc_item(i, t.mod_name, is_builtin) end):to_map()
   t.file = convert_ldoc_file(dump.file)
   t.full_path = file_to_full_path(t.file, t, is_builtin)
   t.last_updated = internal.get_timestamp()
   t.mod_name = t.name

   t.summary = reformat_docstring(t.summary)
   t.description = reformat_docstring(t.description)

   return t
end

-- Makes the object `key` point to the documentation for the file/item
-- indicated by `alias`.
-- @tparam any key
-- @tparam {file_path=string,full_path=string} alias
local function add_alias(key, alias)
   --Log.trace("add alias %s -> %s", key, alias)
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

local function alias_api_table_fields(api_table, req_path)
   if type(api_table) ~= "table" then
      return
   end

   -- Associate functions with their corresponding documentation, so
   -- you can do things like Doc.help(Rand.rnd).
   local tbl = api_table
   if tbl.all_methods then
      tbl = tbl.all_methods
   end

   local entry, file_path = doc_entry_for_req_path(req_path)
   assert(entry, req_path .. " " .. file_path)

   if tbl then
      for k, obj in pairs(tbl) do
         if type(obj) == "function" then
            local full_path = ("%s.%s"):format(req_path, k)
            full_path = full_path:gsub("^ext.", "")

            local item = entry.items[full_path:lower()]
            if item then
               -- This item has documentation available, so add an alias for it.
               add_alias(obj, {file_path=file_path, full_path=full_path, display_name=full_path})
            end
         end
      end
   end

   add_alias(entry.full_path, {file_path=file_path, full_path=entry.full_path, display_name=entry.full_path})
   add_alias(api_table, {file_path=file_path, full_path=entry.full_path, display_name=entry.full_path})
end

local function add_common_aliases(item, file_path)
   local full_path = item.full_path
   local alias = { file_path=file_path, full_path=full_path, display_name=full_path }

   Log.trace("document %s %s", full_path, file_path)

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

   last_updated_time = internal.get_timestamp()

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
      local found
      if aliases then
         for _, alias in ipairs(aliases) do
            local file = doc_store.entries[alias.file_path]
            assert(file, alias.file_path)
            assert(file.file.filename == item.file.filename, ("%s %s"):format(inspect(file.file), inspect(item.file)))
            found = true
            break
         end
      end

         add_common_aliases(item, file_path)

      if is_builtin then
         item.is_builtin = true
      end
   end

   add_common_aliases(result, file_path)

   alias_api_table_fields(api_table, req_path)

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
      if not string.match(file_path, "^__private__:") then
         entry = doc_store.entries[file_path]
      end
   elseif type(path) == "table" then
      if path.__iface then
         path = path.__iface
      elseif path.__class then
         path = path.__class
      end
      entry = nil
   end

   if entry then
      return {
         type = "entry",
         entry = entry
      }
   end

   aliases = doc_store.aliases[path]
   if aliases and #aliases > 0 then
      if #aliases == 1 then
         local alias = aliases[1]
         local file = doc_store.entries[alias.file_path]
         assert(file)

         assert(file.full_path, inspect(file))
         if alias.full_path == file.full_path:lower() then
            -- this is a module
            entry = file
         else
            -- this is an item inside the module
            entry = file.items[alias.full_path]
         end

         assert(entry, alias.full_path)
         return {
            type = "entry",
            entry = entry
         }
      else
         return {
            type = "candidates",
            candidates = fun.iter(aliases):map(function(a) return { a.display_name, a.full_path } end):to_list()
         }
      end
   end

   if path and aliases and aliases[1].file_path ~= path then
      return nil, ("No documentation for %s (%s)"):format(aliases[1].file_path, path)
   else
      return nil, ("No documentation for %s"):format((tostring(path)))
   end
end

local function create_doc_from_location(file_path, loc)
   local file = { base = "", filename = "", relative = "" }

   if loc then
      local relative = loc.relative
      local filename = fs.join(fs.get_working_directory(), relative)
      local base = filename:gsub("/([^/]+)$", "")
      file = {
         base = base,
         filename = filename,
         relative = relative
      }
   end

   return {
      items = {},
      full_path = file_path,
      lineno = loc.line,
      file = file
   }
end

function doc.add_for_data_type(_type, defined_in, summary)
   local file_path = "__private__:data_type"
   local full_path = _type
   assert(full_path)

   if doc_store.entries[file_path] == nil then
      -- BUG data types do not have a provided location
      doc_store.entries[file_path] = create_doc_from_location(file_path, defined_in)
   end

   local the_doc = {
      type = "data type",
      full_path = full_path,
      name = _type,
      file = doc_store.entries[file_path].file,
      lineno = defined_in.line,
      summary = summary or nil
   }

   doc_store.entries[file_path].items[full_path] = the_doc

   local alias = { file_path = file_path, full_path = full_path, display_name = full_path }

   -- "base.chara"
   add_alias(_type, alias)
end

function doc.add_for_data(_type, _id, the_doc, defined_in, dat, force)
   local file_path = "__private__:data"
   local full_path = ("%s:%s"):format(_type, _id)

   if doc_store.entries[file_path] == nil then
      doc_store.entries[file_path] = create_doc_from_location(file_path, defined_in)
   else
      if doc_store.entries[file_path].items[full_path] and not force then
         return
      end
   end

   if type(the_doc) == "string" then
      the_doc = { summary = the_doc }
   end

   assert(type(the_doc) == "table")
   the_doc.type = "data instance"
   the_doc.data_type = _type
   the_doc.name = _id
   the_doc.full_path = full_path
   the_doc.file = doc_store.entries[file_path].file
   the_doc.lineno = defined_in and defined_in.line or 0

   doc_store.entries[file_path].items[full_path] = the_doc

   local alias = { file_path = file_path, full_path = full_path, display_name = full_path }

   -- "base.chara:elona.putit"
   add_alias(full_path, alias)

   -- "elona.putit"
   add_alias(_id, alias)

   -- "putit"
   add_alias(_id:gsub("^([^.]+)%.", ""), alias)

   if dat then
      -- <table 0x12345678>
      add_alias(dat, alias)
   end
end

-- Obtains the chunk with members for documentation associated with
-- `path`. This may be different from the file's chunk, since files in
-- ext/ and ldoc's builtin documentation path are actually documenting
-- stdlib tables, and the result of requiring those files is not a
-- table.
local function get_api_table_for_file(file)
   -- the docs in ext/*.lua and thirdparty/ldoc/builtin/*.lua actually
   -- map to global stdlib tables, not the given files. In this case
   -- we want to require the actual stdlib table instead of the ones
   -- with the documentation.
   local require_original = file:match("thirdparty/ldoc/builtin/[^/.]+%.lua$") or file:match("^ext/[^/.]+%.lua$")

   local success, tbl

   if require_original then
      -- The documentation in this file should be associated with a
      -- chunk other than the file's returned chunk.
      local api_name = fs.filename_part(file)
      if file:match("^thirdparty/ldoc/builtin/") and api_name == "global" then
         -- "global" is just a name used by ldoc to contain all the
         -- global functions like `assert` and `collectgarbage`,
         -- not an actual module.
         --
         -- Since we use strict.lua we have to generate a new table
         -- without the strict metatable containing the global
         -- functions to prevent errors.
         success = true
         tbl = {}
         for k, v in pairs(_G) do
            if type(v) == "function" then
               tbl[k] = v
            end
         end
         Log.trace("Require global: %s", file)
      else
         -- require the original API
         Log.trace("Require original: %s", api_name)
         success, tbl = pcall(require, api_name)
      end
   else
      Log.trace("Require normal: %s", file)
      success, tbl = pcall(require, file)
   end

   return success, tbl
end

function doc.build_for_file(path, tbl)
   local req_path = paths.convert_to_require_path(path)

   local success

   -- Obtain the table from require so we can alias documentation to
   -- its members. This way you can call help(table.concat) or
   -- similar, passing the actual function object instead of a string.
   if tbl ~= nil then
      success = true
   else
      success, tbl = get_api_table_for_file(path)
   end

   if success then
      doc.reparse(req_path, tbl)
   else
      Log.debug("API require failed: %s", tbl)
   end
end

function doc.build_for(dir)
   if fs.is_file(dir) then
      doc.build_for_file(dir)
   else
      for _, api in fs.iter_directory_items(dir .. "/") do
         local path = fs.join(dir, api)
         if fs.is_file(path) and fs.extension_part(path) == "lua" then
            doc.build_for_file(path)
         elseif fs.is_directory(path) then
            doc.build_for(path)
         end
      end
   end
end

function doc.rebuild()
   doc.clear()

   doc.build_for("api")
   doc.build_for("mod")
   doc.build_for("internal")
   doc.build_for("thirdparty/fun.lua")

   -- Lua stdlib
   doc.build_for("thirdparty/ldoc/builtin")

   -- Extension methods for Lua stdlib
   doc.build_for("ext")

   -- Data entries
   local data = require("internal.data")
   for _, _ty, tbl in data:iter() do
      doc.add_for_data_type(_ty, tbl._defined_in, tbl.doc)

      if tbl.on_document then
         for _, dat in tbl:iter() do
            doc.add_for_data(_ty, dat._id, tbl.on_document(dat), dat._defined_in, dat)
         end
      end
   end

   doc.save()
end

function doc.clear()
   doc_store.entries = {}
   doc_store.aliases = {}
   doc_store.can_load = true
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

   Log.info("Saving documentation.")
   SaveFs.write("data/doc", doc_store)

   for _, key in ipairs(remove) do
      doc_store.aliases[key] = remove[key]
   end
end

function doc.load()
   if not SaveFs.exists("data/doc") then
      return
   end

   Log.info("Loading documentation.")
   local ok, new_doc_store = SaveFs.read("data/doc")
   if not ok then
      error(new_doc_store)
   end

   table.replace_with(doc_store, new_doc_store)

   doc_store.can_load = true
   last_updated_time = internal.get_timestamp()
end

function doc.alias_api_tables()
   for path, _ in pairs(doc_store.entries) do
      Log.debug("load doc: %s", path)
      if not string.match(path, "^__private__:") then
         local _, req_path = get_paths(path)
         local success, api_table = get_api_table_for_file(path)
         if success then
            alias_api_table_fields(api_table, req_path)
         end
      end
   end
end

function doc.can_load()
   -- only start loading documentation on require after there has been an
   -- attempt to load the doc store on startup.
   return doc_store.can_load
end

function doc.aliases_for(full_path)
   local the_doc = doc.get(full_path)
   if the_doc and the_doc.entry then
      full_path = the_doc.entry.full_path
   end

   full_path = full_path:lower()

   local aliases = {}
   for k, alias_list in pairs(doc_store.aliases) do
      for _, alias in ipairs(alias_list) do
         if alias.full_path == full_path then
            aliases[#aliases+1] = tostring(k)
         end
      end
   end

   return aliases, full_path
end

return doc
