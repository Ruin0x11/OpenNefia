local Xml = require("mod.extlibs.api.Xml")
local Env = require("api.Env")
local Enum = require("api.Enum")

local cnv = {}

local function to_camel_case(str)
   str = str:gsub("[%-_]+([^%-_])", function(s) return s:upper() end)
   return str:sub(1, 1):upper() .. str:sub(2)
end

local function to_camel_case_id(str)
   return to_camel_case(str:gsub("(.*)%.(.*)", "%2"))
end

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

cnv["base.music"] = {
   name = "MusicDef",
   fields = {
      file = {
         name = "Filepath",
         cb = function(v)
            return v:gsub("mod/[a-zA-Z0-9_]*/sound/", "Assets/Sound/")
         end
      }
   }
}

cnv["base.asset"] = {
   name = "AssetDef",
   attributes = false,
   fields = {
      source = {
         attributes = true,
         name = "SourceImagePath",
         cb = function(v)
            return v:gsub("graphic/", "Assets/Graphic/")
         end
      },
      image = {
         name = "ImagePath",
         cb = function(v)
            return v:gsub("graphic/", "Assets/Graphic/")
         end
      },
      x = { attributes = true },
      y = { attributes = true },
      width = { attributes = true },
      height = { attributes = true },
      count_x = true,
      count_y = true
   }
}

cnv["base.chip"] = {
   name = "ChipDef",
   attributes = true,
   fields = {
      image = {
         name = function(v)
            if type(v) == "table" then
               return "ImageRegion"
            else
               return "ImagePath"
            end
         end,
         cb = function(v)
            if type(v) == "table" then
               local s = ('SourceImagePath="%s" X="%s" Y="%s" Width="%s" Height="%s"'):format(v.source, v.x, v.y, v.width, v.height)
               if v.count_x > 1 then
                  s = s .. (' CountX="%s"'):format(v.count_x)
               end
               return s
            else
               return v:gsub("graphic/", "Assets/Graphic/")
            end
         end
      },
      group = true,
   }
}

cnv["base.map_tile"] = {
   name = "TileDef",
   fields = {
      image = {
         attributes = true,
         name = function(v)
            if type(v) == "table" then
               return "ImageRegion"
            else
               return "ImagePath"
            end
         end,
         cb = function(v)
            if type(v) == "table" then
               local s = ('SourceImagePath="%s" X="%s" Y="%s" Width="%s" Height="%s"'):format(v.source, v.x, v.y, v.width, v.height)
               if v.count_x and v.count_x > 1 then
                  s = s .. (' CountX="%s"'):format(v.count_x)
               end
               return s
            else
               return v:gsub("graphic/", "Assets/Graphic/")
            end
         end
      },
      is_solid = true,
      is_opaque = true,
      is_road = {
         ignore = table.set { "false" }
      },
      wall = {
         cb = function(v)
            return "Core." .. to_camel_case_id(v)
         end
      },
      wall_kind = true,
      kind = {
         enum = Enum.TileRole,
         ignore = table.set { "None" }
      },
      kind2 = {
         enum = Enum.TileRole,
         ignore = table.set { "None" }
      },
      elona_atlas = {
         attributes = true
      },
   }
}

local function convert(_type)
   for _, mod_id in Env.iter_mods() do
      local doc = { xml = "Defs" }
      local def_ofs = {}

      local c = assert(cnv[_type], _type)

      for _, entry in data[_type]:iter():filter(Env.mod_filter(mod_id)) do
         local id = to_camel_case_id(entry._id)

         local t = { xml = c.name, Id = id, ElonaId = entry.elona_id }

         for _, data_field in ipairs(data[_type]:fields()) do
            local field = c.fields[data_field.name]
            local v = entry[data_field.name]

            if field ~= nil and v ~= nil then
               if field == true then
                  field = {
                     name = to_camel_case(data_field.name)
                  }
               end

               local name = field.name or to_camel_case(data_field.name)
               if type(name) == "function" then
                  name = name(v)
               end

               if v then
                  if field.enum then
                     v = field.enum:to_string(v)
                  end
                  if field.cb then
                     v = field.cb(v, entry)
                  end
               end

               local s = tostring(v)
               if not (field.ignore and field.ignore[s]) then
                  if c.attributes or field.attributes then
                     t[name] = tostring(v)
                  else
                     local tn = { xml = name, tostring(v) }
                     t[#t+1] = tn
                  end
               end
            end
         end

         def_ofs[#def_ofs+1] = ("public static %s %s = null!;"):format(c.name, id)
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

convert("base.map_tile")
