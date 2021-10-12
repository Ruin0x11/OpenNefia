local Xml = require("mod.extlibs.api.Xml")
local Env = require("api.Env")

local cnv = {}

cnv["base.sound"] = {
   name = "SoundDef",
   fields = {
      file = {
         name = "Filepath",
         cb = function(v)
            return v:gsub("mod/[a-zA-Z0-9_]*/sound/", "Assets/Sound/")
         end
      }
   }
}

local function to_camel_case_id(str)
   str = str:gsub("(.*)%.(.*)", "%2")
   str = str:gsub("[%-_]+([^%-_])", function(s) return s:upper() end)
   return str:sub(1, 1):upper() .. str:sub(2)
end

local function convert(_type)
   for _, mod_id in Env.iter_mods() do
      local doc = { xml = "Defs" }
      local def_ofs = {}

      local c = assert(cnv[_type], _type)

      for _, entry in data[_type]:iter():filter(Env.mod_filter(mod_id)) do
         local id = to_camel_case_id(entry._id)
         local t = { xml = c.name, Id = id }

         for name, field in pairs(c.fields) do
            local v = entry[name]

            if field.cb then
               v = field.cb(v, entry)
            end

            local tn = { xml = field.name, tostring(v) }
            t[#t+1] = tn

            def_ofs[#def_ofs+1] = ("public static %s %s = null!;"):format(c.name, id)
         end

         doc[#doc+1] = t
      end

      if #doc > 0 then
         local s = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>"
         s  = s .. Xml.from_rapidxml(doc):__tostring("", "    ")

         print("Mod/" .. mod_id .. "Defs/" .. c.name .. ".xml")
         print(s)
         print()

         print("Mod/" .. mod_id .. "Data/" .. c.name .. "Of.cs")
         print("[DefOfEntries]")
         print("public static class " .. c.name .. "Of")
         print("{")
         for _, def_of in ipairs(def_ofs) do
            print("    " .. def_of)
         end
         print("}")
      end
   end
end

convert("base.sound")
