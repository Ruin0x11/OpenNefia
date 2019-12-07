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
   local relative = string.strip_prefix(file.filename, fs.get_working_directory() .. "/")
   return {
      base = file.base,
      filename = file.filename,

      relative = relative
   }
end

local function file_to_full_path(file, item)
   local prefix = paths.convert_to_require_path(file.relative)
   if item == nil then
      return prefix
   end

   return ("%s.%s"):format(prefix, item.name)
end

--- Reformats a docstring such that singular line breaks are joined,
--- while preserving the wrapping of lines with a non-alphabetic first
--- character or more than one consecutive linebreak.
local function reformat_docstring(docstring)
   local res = ""

   docstring:gsub("\r\n", "")
   docstring:gsub("\n\r", "")

   for line in string.lines(docstring) do
      local break_line = true

      local is_blank_line = string.match(line, "^%s*$")

      if string.match(line, "^%s*[A-Za-z]") then
         break_line = false
      end

      _ppr(line, break_line)
      res = res .. line

      if break_line then
         res = res .. "\n"
      end
      if is_blank_line then
         res = res .. "\n"
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

local CONFIG_FILE = "data/ldoc.ld"

function doc.reparse(path, api_table)
   local file_path, req_path = get_paths(path)

   ldoc_config = ldoc_config or read_ldoc_config(CONFIG_FILE)
   print(file_path)
   local dump = ldoc.dump_file(file_path, ldoc_config)[1]


   if dump == nil then
      local warnings = require("thirdparty.ldoc.doc").Item.warnings
      Log.debug("LDoc produced no output for %s", path)
      for _, warning in ipairs(warnings) do
         Log.warn(warning)
      end
      return
   end

   print" go"
   Log.debug("Updating documentation for %s (%s)", req_path, path)

   local result = convert_ldoc(dump)
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
   end

   doc_store.entries[result.full_path] = { file_path=file_path, full_path=result.full_path, is_module = true }

   local function assoc(full_path, v)
      local exist = doc_store.entries[full_path]
      if exist then
         doc_store.entries[v] = exist
      end
   end

   if api_table then
      -- Associate functions with their corresponding documentation,
      -- so you can do things like Doc.lookup(Rand.rnd).
      local tbl = api_table
      if tbl.all_methods then
         tbl = tbl.all_methods
      end
      for k, v in pairs(tbl) do
         if type(v) == "function" then
            local full_path = ("%s.%s"):format(req_path, k)
            assoc(full_path, v)
         end
      end

      -- Make Doc.get(Rand) return the same thing as Doc.get("api.Rand")
      Log.debug("ASSOC, %s %s", req_path, tostring(api_table))
      assoc(req_path, api_table)
   end

   return dump
end

function doc.get(path)
   local file_path, entry

   if type(path) == string then
      file_path = get_paths(path)
      entry = doc_store.files[file_path]
   end

   if entry == nil then
      local file_path = doc_store.entries[path]
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
      if file_path and file_path ~= path then
         return nil, ("No documentation for %s (%s)"):format(file_path, path)
      else
         return nil, ("No documentation for %s"):format(path)
      end
   end

   return entry
end

function doc.save()
end

function doc.load()
end

return doc
