local mod_info = require("internal.mod_info")
local Env = require("api.Env")

local function build_tree(mods)
   local nodes = {
      _root = { id = "_root", name = "OpenNefia API", version = Env.api_version() }
   }

   local load_order = mod_info.calculate_load_order(mods)
   for _, m in ipairs(load_order) do
      local mod_id = m.id
      local manifest = assert(mod_info.load_manifest(m.manifest_path))
      nodes[mod_id] = { id = mod_id, name = mod_id, version = manifest.version }
      if mod_id == "base" then
         table.insert(nodes._root, nodes[mod_id])
      end
      for dep_id, version in pairs(manifest.dependencies) do
         table.insert(nodes[dep_id], nodes[mod_id])
      end
   end

   return nodes
end

local function print_tree(start, tree, indent_width, stream)
   local function _print_tree(parent, grandparent, indent)
      if grandparent or start == parent then
         stream:write(("%s (%s)\n"):format(parent.name, parent.version))
      else
         stream:write(("%s (%s)"):format(parent.name, parent.version))
      end
      if not tree[parent.id] then
         return
      end
      for i, child in ipairs(tree[parent.id]) do
         if i == #tree[parent.id] then
            stream:write(indent .. "└" .. ("─"):rep(indent_width))
            _print_tree(child, parent, indent .. " " .. (" "):rep(4))
         else
            stream:write(indent .. "├" .. ("─"):rep(indent_width))
            _print_tree(child, parent, indent .. "│" .. (" "):rep(4))
         end
      end
   end

   local parent = start
   _print_tree(parent, nil, "")
end

return function(args)
   local mods = mod_info.scan_mod_dir()
   local tree = build_tree(mods)
   print_tree(tree._root, tree, 4, io.stdout)
end
