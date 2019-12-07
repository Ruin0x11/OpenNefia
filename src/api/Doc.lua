--- Module for looking up documentation interactively.
---
--- Elona_next features an interactive documentation system. If you
--- want to understand what something does, you can use `Doc.lookup`
--- in the REPL and get back a description for modules, functions, and
--- various other pieces of data.
---
---   Doc.lookup("api.chara.IChara.ether_disease_corruption")
---   Doc.lookup(Map.generate)
---   Doc.lookup("base.on_chara_moved")
---   Doc.lookup("elona_sys")
---   Doc.lookup(ILocation)
---
local Doc = {}

local doc = require("internal.doc")

function Doc.get(thing)
   return doc.get(thing)
end

local function string_is_empty(str)
   return str == nil or string.match(str, "^%s*$")
end

function Doc.lookup(thing, qualifier)
   local the_doc, err = Doc.get(thing)
   if err then
      return err
   end

   local name
   if the_doc.type == "module" then
      name = the_doc.full_path
   elseif the_doc.type == "function" then
      name = ("%s.%s()"):format(the_doc.mod_name, the_doc.name)
   else
      name = ("%s.%s"):format(the_doc.mod_name, the_doc.name)
   end

   local sig = ""
   if the_doc.type == "function" then
      sig = ("\n\n%s.%s%s"):format(the_doc.mod_name, the_doc.name, the_doc.args)
   end

   local line = ""
   if the_doc.type ~= "module" then
      line = (" on line %d"):format(the_doc.lineno)
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

   return ([[
'%s' is a %s defined in '%s'%s.%s%s%s
]]):format(name, the_doc.type, the_doc.file.relative, line, sig, summary, desc)
end

function Doc.jump_to(thing, qualifier)
   local d, err = doc.get(thing)
   if err then
      error(err)
   end

   return ("%s:%d:0"):format(d.file.filename, d.lineno)
end

function Doc.on_hotload(old, new)
   table.replace_with(old, new)
   rawset(_G, "help", Doc.lookup)
end

return Doc
