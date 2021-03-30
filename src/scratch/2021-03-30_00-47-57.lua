local ArchiveUnpacker = require("mod.cdata_tools.api.archive.ArchiveUnpacker")
local Log = require("api.Log")
local CustomItemDecoder = require("mod.cdata_tools.api.citem.CustomItemDecoder")
local CodeGenerator = require("api.CodeGenerator")
local fs = require("util.fs")
local paths = require("internal.paths")
local CustomNpcDecoder = require("mod.cdata_tools.api.cnpc.CustomNpcDecoder")

Log.set_level("debug")

--[[
local layout = {
   ["servant.t"] = {
      type = "archive",
      layout = {}
   },
   ["gem.t"] = {
      type = "archive",
      layout = {}
   },
   ["artifact.t"] = {
      type = "archive",
      layout = {}
   },
   ["branch.t"] = {
      type = "archive",
      layout = {}
   },
   ["ground.t"] = {
      type = "archive",
      layout = {}
   },
}

local archive = ArchiveUnpacker.unpack_file("mod/cgod_madoka/Madoka of Fortune Circle.god", { layout = layout })
--]]

local converters = {}

function converters.item(name, mod_id, raw, root)
   local decoded = CustomItemDecoder.decode(raw, mod_id, name)

   local image_path = ("graphic/item/%s.bmp"):format(name)
   decoded.chip.proto.image = fs.join(root, image_path)

   return {
      [image_path] = decoded.chip._bmp,
      ["data/item.lua"] = decoded.data,
      ["data/chip.lua"] = decoded.chip,
      ["locale/en/item.lua"] = decoded.locale_data.en,
      ["locale/jp/item.lua"] = decoded.locale_data.jp
   }
end

function converters.npc(name, mod_id, raw, root)
   local decoded = CustomNpcDecoder.decode(raw, mod_id, name)

   local image_path = ("graphic/chara/%s.bmp"):format(name)
   decoded.chip.proto.image = fs.join(root, image_path)

   return {
      [image_path] = decoded.chip._bmp,
      ["data/chara.lua"] = decoded.data,
      ["data/chip.lua"] = decoded.chip,
      ["locale/en/chara.lua"] = decoded.locale_data.en,
      ["locale/jp/chara.lua"] = decoded.locale_data.jp
   }
end

function converters.map(name, mod_id, raw, root)
   return {}
end

function converters.god(name, mod_id, raw, root)
   return {}
end

local function convert_god(hll, mod_id, root)
   local layout = {}
   local targets = {}

   for k, v in pairs(hll) do
      local optional
      if v:sub(#v) == "?" then
         optional = true
         v = v:sub(0, #v-1)
      end

      if not converters[v] then
         error("unknown directive " .. v)
      end

      if k ~= "top" then
         layout[k] = {
            type = "archive",
            layout = {}
         }
      end

      targets[k] = { kind = v, optional = optional }
   end

   local archive = ArchiveUnpacker.unpack_file("mod/cgod_madoka/Madoka of Fortune Circle.god", { layout = layout })

   local result = {}

   for k, target in pairs(targets) do
      local raw
      if k == "top" then
         raw = archive
      else
         raw = archive[k]
      end
      if (not raw or table.count(raw) == 0) and not target.optional then
         error("Missing expected archive item " .. k)
      end

      local name = k:gsub("^(.*)%..*", "%1")
      result[k] = converters[target.kind](name, mod_id, raw, root)
   end

   return result
end

local function serialize_god(converted, root)
   local file_to_content = {}
   local locale_files = {}
   local data_requires = {}
   local data_file_requires = {}

   for _, result in pairs(converted) do
      for filename, content in pairs(result) do
         local path = fs.join(root, filename)

         if filename:match("^locale/") then
            locale_files[path] = locale_files[path] or {}
            table.merge_ex(locale_files[path], content)
         elseif filename:match("^data/") then
            local proto = assert(content.proto)
            local requires = assert(content.requires)
            for _, req_path in ipairs(requires) do
               data_file_requires[path] = data_file_requires[path] or {}
               data_file_requires[path][req_path] = true
            end

            local first = file_to_content[path] == nil
            file_to_content[path] = file_to_content[path] or ""

            local gen = CodeGenerator:new()
            if not first then
               gen:tabify()
               gen:tabify()
            end
            gen:write("data:add ")
            gen:write_table(proto)

            file_to_content[path] = file_to_content[path] .. tostring(gen)

            local require_path = paths.convert_to_require_path(path)
            data_requires[require_path] = true
         elseif filename:match("^graphic/") then
            file_to_content[path] = content
         else
            error(filename)
         end
      end
   end

   for path, locale in pairs(locale_files) do
      local gen = CodeGenerator:new()
      gen:write("return ")
      gen:write_table(locale)

      file_to_content[path] = tostring(gen)
   end

   local function mkrequire(req_path)
      return ("require(\"%s\")"):format(req_path)
   end

   for path, req_paths in pairs(data_file_requires) do
      local prelude = {}
      for req_path, _ in pairs(req_paths) do
         local name = req_path:gsub("^.*%.([^.]+)$", "%1")
         prelude[#prelude+1] = ("local %s = require(\"%s\")"):format(name, req_path)
      end
      if #prelude > 0 then
         prelude[#prelude+1] = "\n"
      end
      file_to_content[path] = table.concat(prelude, "\n") .. file_to_content[path]
   end

   data_requires = table.keys(data_requires)
   table.sort(data_requires)
   local data_init = {}
   for _, req_path in ipairs(data_requires) do
      data_init[#data_init+1] = ("require(\"%s\")"):format(req_path)
   end
   local data_init_path = fs.join(root, "data/init.lua")
   file_to_content[data_init_path] = table.concat(data_init, "\n")

   local init_path = fs.join(root, "init.lua")
   local data_init_req_path = paths.convert_to_require_path(data_init_path)
   file_to_content[init_path] = ("require(\"%s\")"):format(data_init_req_path)

   return file_to_content
end

local function write_serialized(file_to_content)
   for path, content in pairs(file_to_content) do
      local parent = fs.parent(path)
      fs.create_directory(parent)
      fs.write(path, content)
   end
end

local hll = {
   top = "god",
   ["artifact.t"] = "item",
   ["servant.t"] = "npc",
   ["gem.t"] = "item",
   ["branch.t"] = "npc?",
   ["ground.t"] = "map?",
}

local converted = convert_god(hll, "cgod_madoka", "mod/cgod_madoka")

local serialized = serialize_god(converted, "mod/cgod_madoka")

write_serialized(serialized)
