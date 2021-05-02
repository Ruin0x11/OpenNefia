local Log = require("api.Log")
local Rand = require("api.Rand")
local Stopwatch = require("api.Stopwatch")
local mod = require("internal.mod")
local fs = require("util.fs")
local dawg = require("internal.dawg")
local data = require("internal.data")

local i18n = {}
i18n.db = {}
i18n.index = nil
i18n.key_index = nil
i18n.data = {}

local reify_one
reify_one = function(_db, item, key)
   if type(item) == "string" or type(item) == "function" then
      _db[key] = item
   elseif type(item) == "table" then
      if item[1] then
         -- List of options; one is chosen at random.
         _db[key] = item
      else
         -- Nested list of keys.
         for k, v in pairs(item) do
            local next_key
            if key == "" then
               next_key = k
            else
               next_key = key .. "." .. k
            end
            reify_one(_db, v, next_key)
         end
      end
   else
      error("unknown type: " .. key)
   end
end

function i18n.load_single_translation(path, merged, localize, namespace)
   path = fs.normalize(path)
   Log.debug("Loading translations at %s", path)
   local chunk, err = love.filesystem.load(path)

   if chunk == nil then
      error("Error loading translations:\n\t" .. err)
   end

   setfenv(chunk, i18n.env)

   local ok, result = xpcall(chunk, function(err) return debug.traceback(err, 2) end)

   if not ok then
      error("Error loading translations: " .. result)
   end
   if type(result) ~= "table" then
      error("Error loading translations: returned type not a table (" .. path .. ")")
   end

   reify_one(merged, result, "")

   for k, v in pairs(result) do
      local _type = namespace .. "." .. k
      if rawget(data, "schemas")[_type] then
         localize[_type] = localize[_type] or {}
         if type(v) == "table" and v._ then
            for mod_id, v in pairs(v._) do
               for name, v in pairs(v) do
                  local _id = ("%s.%s"):format(mod_id, name)
                  if data[_type][_id] then
                     localize[_type][_id] = {}
                     reify_one(localize[_type][_id], v, "")
                  end
               end
            end
         end
      end
   end
end

local load_translations
load_translations = function(path, merged, localize, namespace)
   merged[namespace] = merged[namespace] or {}

   for _, file in fs.iter_directory_items(path) do
      local full_path = fs.join(path, file)
      if fs.is_file(full_path) and fs.can_load(full_path) then
         i18n.load_single_translation(full_path, merged[namespace], localize, namespace)
      end
   end
end

i18n.load_translations = load_translations

function i18n.switch_language(lang, force)
   local lang_data = data["base.language"]:ensure(lang)
   i18n.language_id = lang
   i18n.language = lang_data.language_code
   local ok, env = pcall(require, "internal.i18n.env." .. i18n.language)
   if not ok then
      error(("Could not require I18N environment '%s': %s"):format(lang, env))
   end
   i18n.env = env

   i18n.env["get"] = i18n.get
   i18n.env["rnd"] = Rand.rnd

   if i18n.db[i18n.language] == nil or force then
      i18n.db[i18n.language] = {}
   end
   if i18n.data[i18n.language] == nil or force then
      i18n.data[i18n.language] = {}
   end

   i18n.index = nil

   local sw = Stopwatch:new()

   for _, mod in mod.iter_loaded() do
      local locale_folder = fs.join(mod.root_path, "locale")

      if fs.is_directory(locale_folder) then
         local path = fs.join(locale_folder, i18n.language)
         if fs.is_directory(path) then
            i18n.load_translations(path, i18n.db[i18n.language], i18n.data[i18n.language], "base")
            for _, item in fs.iter_directory_items(path) do
               local full_path = fs.join(path, item)
               if fs.is_directory(full_path) then
                  local namespace = item
                  i18n.load_translations(full_path, i18n.db[i18n.language], i18n.data[i18n.language], namespace)
               end
            end
         end
      end
   end

   Log.debug("Translations for language '%s' loaded in %02.02fms", i18n.language_id, sw:measure())
end

function i18n.get_language()
   return i18n.language
end

function i18n.get_language_id()
   return i18n.language_id
end

local function get_namespace_and_key(key)
   if type(key) ~= "string" then
      return "base", tostring(key)
   end

   local pos = key:find(":")
   if pos == nil then
      -- If the namespace is omitted, assume it's `base`.
      return "base", key
   end

   return key:sub(1, pos-1), key:sub(pos+1)
end

function i18n.get_array(full_key, ...)
   local namespace, key = get_namespace_and_key(full_key)
   local root = i18n.db[i18n.language][namespace]
   if not root then
      return nil
   end
   local entry = root[key]
   if not entry then
      return nil
   end

   if type(entry) == "table" and entry[1] then
      return entry
   elseif type(entry) ~= nil then
      return { entry }
   end

   return nil
end

function i18n.get(full_key, ...)
   local namespace, key = get_namespace_and_key(full_key)
   local root = i18n.db[i18n.language]
   if not root then
      return nil
   end
   local ns = root[namespace]
   if not ns then
      return nil
   end
   local entry = ns[key]
   if not entry then
      return nil
   end

   if type(entry) == "table" and entry[1] then
      entry = Rand.choice(entry)
   end

   if type(entry) == "string" then
      return entry
   elseif type(entry) == "function" then
      local success, result = pcall(entry, ...)
      if not success then
         return ("<error [%s:%s]: %s>"):format(namespace, key, result)
      end
      return result
   end

   return nil
end

function i18n.localize(_type, _id, key, ...)
   local cache = i18n.data[i18n.language]

   if cache[_type] == nil then
      return nil
   end
   local for_type = cache[_type]
   if for_type[_id] == nil then
      return nil
   end

   local entry = for_type[_id][key]

   if type(entry) == "table" and entry[1] then
      entry = Rand.choice(entry)
   end

   if type(entry) == "string" then
      return entry
   elseif type(entry) == "function" then
      local success, result = pcall(entry, ...)
      if not success then
         return ("<error [%s:%s._%s]: %s>"):format(_type, _id, key, result)
      end
      return result
   end

   return nil
end

function i18n.capitalize(text)
   -- Find the "capitalize" function defined in the I18N environment.
   local cap = i18n.env.capitalize
   if type(cap) ~= "function" then
      return text
   end

   return cap(text)
end

-- Some strings like the ones for the in-game manual will cause the dawg index
-- to explode.
local MAX_LOOKUP_LEN = 1000

function i18n.make_prefix_lookup()
   local d = dawg:new()
   local corpus = {}
   local add
   add = function(namespace, id, item)
      local full_id = id
      if namespace ~= "base" then
         full_id = namespace .. ":" .. id
      end
      if type(item) == "string" then
         corpus[item] = corpus[item] or {}
         table.insert(corpus[item], full_id)
      elseif type(item) == "function" then
         local ok, result = pcall(item, {}, {}, {}, {}, {})
         if ok and type(result) == "string" then
            corpus[result] = corpus[result] or {}
            table.insert(corpus[result], full_id)
         end
      elseif type(item) == "table" then
         for _, v in ipairs(item) do
            add(namespace, id, v)
         end
      end
   end
   for namespace, t in pairs(i18n.db[i18n.language]) do
      for id, item in pairs(t) do
         add(namespace, id, item)
      end
   end

   local keys = table.keys(corpus)
   table.sort(keys)

   for _, str in pairs(keys) do
      if str:len() < MAX_LOOKUP_LEN then
         local ids = corpus[str]
         d:insert(str, ids)
      end
   end

   d:finish()

   return d
end

function i18n.search(prefix)
   if i18n.index == nil then
      Log.warn("Building i18n search index.")
      i18n.index = i18n.make_prefix_lookup()
   end
   local results = i18n.index:search(prefix)
   local final = {}
   local seen = table.set {}
   for _, t in ipairs(results) do
      for _, id in ipairs(t) do
         if not seen[id] then
            final[#final+1] = id
            seen[id] = true
         end
      end
   end
   return final
end

function i18n.make_key_prefix_lookup()
   local d = dawg:new()
   local corpus = {}

   for namespace, t in pairs(i18n.db[i18n.language]) do
      for id, item in pairs(t) do
         local full_id = namespace .. ":" .. id
         corpus[#corpus+1] = full_id
      end
   end

   table.sort(corpus, function(a, b) return a < b end)

   for _, key in ipairs(corpus) do
      d:insert(key, key)
   end

   d:finish()

   return d
end

function i18n.search_keys(prefix)
   if i18n.key_index == nil then
      Log.warn("Building i18n key search index.")
      i18n.key_index = i18n.make_key_prefix_lookup()
   end
   return i18n.key_index:search(prefix)
end

function i18n.on_hotload(old, new)
   table.replace_with(old, new)
   i18n.switch_language(old.language or "base.english")
end

return i18n
