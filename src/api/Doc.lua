--- Module for looking up documentation interactively.
---
--- OpenNefia features an interactive documentation system. If you
--- want to understand what something does, you can use `Doc.help`
--- in the REPL to get documentation for modules, functions, and
--- various other pieces of data.
---
---   Doc.help("api.Rand")
---
--- `Doc.help` is aliased to the `help` global variable, so you can
--- call it instead if you want.
---
---   help "api.chara.IChara.ether_disease_corruption"
---   help "base.on_chara_moved"
---   help "elona_sys"
---   help(Map.generate)
---   help(ILocation)
---   help(chara.set_pos)
---
--- To ensure your documentation can be picked up in this system, be
--- sure you have a docstring comment at the top of each Lua file and
--- comments on relevant functions or fields.
--- @module Doc
local Doc = {}

local doc = require("internal.doc")
local fs = require("util.fs")

--- Obtains documentation for `thing`.
---
--- See `Doc.help` for details on the accepted types of `thing`.
---
--- @tparam any thing
--- @see Doc.help
function Doc.get(thing)
   return doc.get(thing)
end

local function string_is_empty(str)
   return str == nil or string.match(str, "^%s*$")
end

function Doc.make_params_string(the_doc)
   if the_doc.type ~= "function" then
      return ""
   end

   local params = "("
   for i, name in ipairs(the_doc.params) do
      local modifier = the_doc.modifiers.param[i]

      if i > 1 then
         params = params .. " -> "
      end
      if modifier and modifier.type then
         params = params .. modifier.type
         if modifier.opt then
            params = params .. "?"
         end
      elseif name == "..." then
         params = params .. name
      else
         params = params .. "<?>"
      end
   end

   local ret = the_doc.modifiers["return"]
   if #ret > 0 then
      params = params .. ") => " .. ret[1].type
      if ret[1].opt then
         params = params .. "?"
      end
   elseif the_doc.is_undocumented then
      params = params .. ") => <?>"
   else
      params = params .. ") => ()"
   end

   return params
end

--- Obtains a documentation summary for `thing`.
---
--- `thing` can be one of the following:
---
--- - A fully qualified module name ("api.Rand")
--- - A fully qualified module and field name ("api.Rand.one_in")
--- - An API, class or interface table (Rand)
--- - A function on an API, class or interface table (Rand.one_in)
---
--- This function is also aliased globally as `help`, so calling
--- `help()` has the same effect as this function.
---
--- @tparam any thing
--- @treturn string
function Doc.help(thing)
   local result, err = Doc.get(thing)
   if err then
      return err
   end

   if result.type == "candidates" then
      return "Multiple candidates: " .. inspect(result.candidates)
   end

   local the_doc = result.entry

   local name
   if the_doc.type == "module" or the_doc.type == "classmod" then
      if the_doc.is_builtin then
         name = the_doc.mod_name
      else
         name = the_doc.full_path
      end
   elseif the_doc.type == "function" then
      name = doc.get_item_full_name(the_doc)
   else
      name = the_doc.full_path
   end

   local _type = ("a %s%s"):format(the_doc.is_builtin and "builtin " or "", the_doc.type)
   if the_doc.type == "data instance" then
      _type = _type .. (" of '%s'"):format(the_doc.data_type)
   end

   local defined = ""
   if not the_doc.is_builtin then
      local path = fs.join(fs.get_working_directory(), the_doc.file.relative)
      defined = (" defined in [%s](%s) on line %d"):format(the_doc.file.relative, path, the_doc.lineno)
   end

   local sig = ""
   if the_doc.signature then
      sig = "\n\n" .. the_doc.signature
   elseif the_doc.type == "function" then
      local params_str = Doc.make_params_string(the_doc)
      sig = ("\n\n```lua\n%s%s :: %s\n```"):format(doc.get_item_full_name(the_doc), the_doc.args, params_str)
   end

   local summary
   if string_is_empty(the_doc.summary) then
      summary = "\n\n  (No description available.)"
   else
      summary = ("\n\n  %s"):format(the_doc.summary)
   end

   local desc = ""
   if not string_is_empty(the_doc.description) then
      desc = ("\n\n%s"):format(the_doc.description)
   end

   local params = ""
   if the_doc.params then
      params = "\n\n### Parameters\n"
      if #the_doc.params == 0 then
         params = params .. " * (none)"
      else
         for i, param_name in ipairs(the_doc.params) do
            local modifier = the_doc.modifiers.param[i]

            if i > 1 then
               params = params .. "\n"
            end
            params = params .. " * `" .. param_name .. "`"

            local ty = "<?>"
            local opt = false
            if modifier and modifier.type then
               ty = modifier.type
               opt = modifier.opt
            elseif param_name == "..." then
               ty = "..."
            end
            params = params .. (" :: `%s%s`"):format(ty, opt and "?" or "")

            local desc = string.strip_whitespace(the_doc.params.map[param_name])
            if desc ~= "" then
               params = params .. ": " .. desc
            end
         end
      end
   end

   if the_doc.modifiers then
      local ret = the_doc.modifiers["return"]
      if ret and #ret > 0 then
         params = params .. "\n\n### Returns\n"
         for i, retval in ipairs(ret) do
            if i > 1 then
               params = params .. "\n"
            end
            params = params .. " * `" .. retval.type
            if retval.opt then
               params = params .. "?"
            end
            params = params .. "`"
         end
      end
   end

   local text2 = ("%s%s%s"):format(summary, desc, params)

   local text = ([[
`%s` is %s%s.%s%s
]]):format(name, _type, defined, sig, text2)

   return text
end

--- @tparam string mod
--- @treturn string
function Doc.summarize(mod)
   local result, err = Doc.get(mod)
   if err then
      return err
   end

   if result.type == "candidates" then
      return "Multiple candidates: " .. inspect(result.candidates)
   end

   local the_mod_doc = result.entry

   if the_mod_doc.type ~= "module" and the_mod_doc.type ~= "classmod" then
      return "Object is not a module."
   end

   if type(mod) == "string" then
      mod = require(mod)
   end

   local names = {}
   local indent = 0
   for k, v in pairs(mod) do
      local name = ("%s.%s"):format(the_mod_doc.name, k)
      local the_doc = Doc.get(v)
      if the_doc == nil then
         the_doc = Doc.get(name)
      end
      if the_doc and the_doc.type == "entry" then
         indent = math.max(indent, string.len(name) + 2)
         names[#names+1] = { name, the_doc.entry }
      end
   end

   table.sort(names, function(a, b) return a[2].lineno < b[2].lineno end)

   local res = ""
   for _, v in ipairs(names) do
      if res ~= "" then
         res = res .. "\n"
      end

      local name = v[1]
      local the_doc = v[2]
      local types = {
         module = "m",
         ["function"] = "f",
         field = "v"
      }
      local ty = types[the_doc.type] or "?"
      local summary = string.strip_whitespace(the_doc.summary)
      if summary == "" then
         summary = "(No documentation available.)"
      end
      res = res .. ("[%s] %s:%s%s"):format(ty, name, string.rep(" ", indent - string.len(name)), summary)
   end

   if res == "" then
      return "No items with documentation in this module."
   end

   return res
end

function Doc.make_ldoc_doc(dat, params, returns)
   local the_doc = {
      summary = "<summary>",
      description = dat._doc,
      params = { map = {} },
      full_path = dat._type .. ":" .. dat._id,
      modifiers = {
         param = {},
         ["return"] = {}
      },
      signature = ""
   }

   params = params or {}

   for i, v in ipairs(params) do
      the_doc.params[i] = v.name
      the_doc.params.map[v.name] = v.desc
      local opt = string.find(v.type, "%?$")
      if opt then
         v.type = v.type:sub(1, opt-1)
      end
      table.insert(the_doc.modifiers.param, { type = v.type, opt = not not opt })
   end

   returns = returns or {}

   for _, v in ipairs(returns) do
      local opt = string.find(v.type, "%?$")
      if opt then
         v.type = v.type:sub(1, opt-1)
      end
      table.insert(the_doc.modifiers["return"], { type = v.type, opt = not not opt })
   end

   return the_doc
end

function Doc.on_hotload(old, new)
   table.replace_with(old, new)
   rawset(_G, "help", Doc.help)
   local field = require("game.field")
   if field.repl then
      field.repl.env.help = Doc.help
   end
end

return Doc
