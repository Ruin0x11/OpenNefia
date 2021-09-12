local env = require("internal.env")
local Env = require("api.Env")
local Log = require("api.Log")
local ICloneable = require("api.ICloneable")
local IDrawLayer = require("api.gui.IDrawLayer")

local DrawLayerSpec = class.class("DrawLayerSpec", ICloneable)

function DrawLayerSpec:init()
   self.layers = {}
end

function DrawLayerSpec:iter()
   return fun.wrap(next, self.layers, nil)
end

function DrawLayerSpec:register_draw_layer(tag, require_path_or_layer, z_order, enabled)
   Env.assert_is_valid_ident(tag)
   local instance, require_path
   if type(require_path_or_layer) == "string" then
      require_path = require_path_or_layer
   elseif class.is_an(IDrawLayer, require_path_or_layer) then
      instance = require_path_or_layer
      require_path = assert(Env.get_require_path(instance))
   else
      error(("Invalid draw layer or require path: %s"):format(require_path_or_layer))
   end
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
   self.layers[tag] = {
      require_path = require_path,
      instance = instance or nil,
      z_order = z_order,
      enabled = not not enabled
   }
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
   for tag, layer in pairs(self.layers) do
      new.layers[tag] = layer
   end
   return new
end

return DrawLayerSpec
