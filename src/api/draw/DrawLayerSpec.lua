local env = require("internal.env")
local Env = require("api.Env")
local Log = require("api.Log")
local ICloneable = require("api.ICloneable")

local DrawLayerSpec = class.class("DrawLayerSpec", ICloneable)

function DrawLayerSpec:init()
   self.layers = {}
end

function DrawLayerSpec:iter()
   return next, self.layers, nil
end

function DrawLayerSpec:register_draw_layer(tag, require_path, z_order, enabled)
   Env.assert_is_valid_ident(tag)
   assert(type(require_path) == "string")
   assert(type(z_order) == "number" or z_order == nil)

   local mod = env.find_calling_mod()
   tag = ("%s.%s"):format(mod, tag)
   if enabled == nil then
      enabled = true
   end

   if env.is_hotloading() then
      Log.warn("Skipping draw layer register of '%s'", require_path)
      return
   end
   if self.layers[tag] then
      error("Draw layer " .. tag .. " already registered")
   end
   self.layers[tag] = { require_path = require_path, z_order = z_order, enabled = not not enabled }
end

function DrawLayerSpec:set_draw_layer_enabled(tag, enabled)
   if not self.layers[tag] then
      error(("Layer '%s' isn't registered"):format(tag))
   end
   enabled = not not enabled
   self.layers[tag].enabled = enabled
end

function DrawLayerSpec:clone()
   local new = DrawLayerSpec:new()
   new.layers = table.deepcopy(self.layers)
   return new
end

return DrawLayerSpec
