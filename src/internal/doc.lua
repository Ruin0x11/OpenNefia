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

local function file_to_full_path(file, item)
   local prefix = paths.convert_to_require_path(file.relative)
   if item == nil then
      return prefix:lower()
   end

   return ("%s.%s"):format(prefix, item.name):lower():gsub(":", ".")
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

local function convert_ldoc_item(item, mod_name)
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

   if item.file == nil then
      error(inspect(item))
   end
   t.mod_name = mod_name
   t.file = convert_ldoc_file(item.file)
   t.full_path = file_to_full_path(t.file, item)

   t.summary = reformat_docstring(t.summary)
   t.description = reformat_docstring(t.description)

   return t.full_path, t
end

-- Strips unnecessary info from ldoc's raw output.
local function convert_ldoc(dump)
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

   t.items = fun.wrap(ipairs(dump.items)):map(function(i) return convert_ldoc_item(i, t.mod_name) end):to_map()
   t.file = convert_ldoc_file(dump.file)
   t.full_path = file_to_full_path(t.file)
   t.last_updated = os.time()

   t.summary = reformat_docstring(t.summary)
   t.description = reformat_docstring(t.description)

   return t
end

local function assoc(full_path, v)
   local exist = doc_store.entries[full_path]
   if exist then
      doc_store.entries[v] = exist
      assert(doc_store.files[exist.file_path])
   end
end

local function associate_api_fields(api_table, req_path)
   -- Associate functions with their corresponding documentation,
   -- so you can do things like Doc.help(Rand.rnd).
   local tbl = api_table
   if tbl.all_methods then
      tbl = tbl.all_methods
   end

   if tbl then
      for k, v in pairs(tbl) do
         if type(v) == "function" then
            local full_path = ("%s.%s"):format(req_path, k):lower()
            assoc(full_path, v)
         end
      end
   end

   -- Make Doc.get(Rand) return the same thing as Doc.get("api.Rand")
   print("Assoc",req_path:lower(),api_table)
   assoc(req_path:lower(), api_table)
end

local CONFIG_FILE = "data/ldoc.ld"

function doc.reparse(path, api_table, is_builtin)
   local file_path, req_path = get_paths(path)

   ldoc_config = ldoc_config or read_ldoc_config(CONFIG_FILE)
   local dump = ldoc.dump_file(file_path, ldoc_config)[1]

   if dump == nil then
      local warnings = require("thirdparty.ldoc.doc").Item.warnings
      Log.debug("LDoc produced no output for %s", path)
      for _, warning in ipairs(warnings) do
         Log.warn(warning)
      end
      return false
   end

   Log.info("Updating documentation for %s (%s)", req_path, path)

   local result = convert_ldoc(dump)
   if is_builtin then
      result.is_builtin = true
   end
   doc_store.files[file_path] = result

   local seen = table.set {}
   for full_path, item in pairs(result.items) do
      if seen[full_path] then
         error(full_path)
      end
      seen[full_path] = true

      local exist = doc_store.entries[full_path]
      if exist then
         local file = doc_store.files[exist.file_path]
         assert(file)
         assert(file.file.filename == item.file.filename)
      end
      doc_store.entries[full_path] = { file_path=file_path, full_path=full_path }

      if is_builtin then
         item.is_builtin = true
      end
      if string.match(full_path, "ext") then
         print(item.summary)
      end
   end

   doc_store.entries[result.full_path] = { file_path=file_path, full_path=result.full_path, is_module = true }

   if api_table then
      associate_api_fields(api_table, req_path)
   end

   return true
end

function doc.get(path)
   local file_path, entry

   if type(path) == "string" then
      path = path:lower()
      if string.find(path, "^ext%.") then
         path = path:gsub("^ext%.", "")
      end
      file_path = get_paths(path)
      entry = doc_store.files[file_path]
   elseif type(path) == "table" then
      if path.__iface then
         path = path.__iface
      elseif path.__class then
         path = path.__class
      end
      entry = nil
   end

   if entry == nil then
      file_path = doc_store.entries[path]
      if file_path then
         local file = doc_store.files[file_path.file_path]
         if file then
            if file_path.is_module then
               entry = file
            else
               entry = file.items[file_path.full_path]
            end
         end
      end
   end

   if entry == nil then
      if path and file_path and file_path ~= path then
         return nil, ("No documentation for %s (%s)"):format(file_path, path)
      else
         return nil, ("No documentation for %s"):format(path)
      end
   end

   return entry
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
   doc.build_for("api")
   doc.build_for("mod")

   -- ext
   local ext_dir = "ext"
   for _, api in fs.iter_directory_items(ext_dir) do
      local path = fs.join(ext_dir, api)
      if fs.is_file(path) and fs.extension_part(path) == "lua" then
         local req_path = paths.convert_to_require_path(path)

         -- require the original API
         local success, tbl = pcall(require, api)

         if success then
            assert(type(tbl) == "table", api)
            doc.reparse(req_path, tbl)
         else
            Log.debug("API require failed: %s", tbl)
         end
      end
   end

   -- Lua stdlib
   local builtin_dir = "thirdparty/ldoc/builtin"
   for _, api in fs.iter_directory_items(builtin_dir) do
      local path = fs.join(builtin_dir, api)
      if fs.is_file(path) and fs.extension_part(path) == "lua" then
         local req_path = paths.convert_to_require_path(path)

         -- require the original API
         local success, tbl = pcall(require, api)

         if success then
            doc.reparse(req_path, tbl, true)
         else
            Log.debug("API require failed: %s", tbl)
         end
      end
   end
end

function doc.clear()
   doc_store.entries = {}
   doc_store.files = {}
   doc_store.can_load = true
end

local function doc_store_path()
   return fs.join("data", "doc")
end

function doc.save()
   local remove = {}
   for k, _ in pairs(doc_store.entries) do
      if type(k) ~= "string" then
         remove[#remove+1] = k
      end
   end
   for _, key in ipairs(remove) do
      remove[key] = doc_store.entries[key]
      doc_store.entries[key] = nil
   end

   local str = SaveFs.serialize(doc_store)
   local path = doc_store_path()
   local dirs = fs.parent(path)
   fs.create_directory(dirs)

   Log.info("Saving documentation to %s.", path)
   fs.write(path, str)

   for _, key in ipairs(remove) do
      doc_store.entries[key] = remove[key]
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

   for p, _ in pairs(doc_store.files) do
      local file_path, req_path = get_paths(p)
      local api_table = require(file_path)
      associate_api_fields(api_table, req_path)
   end

   doc_store.can_load = true
end

function doc.can_load()
   -- only start loading documentation on require after there has been an
   -- attempt to load the doc store on startup.
   return doc_store.can_load
end

return doc
