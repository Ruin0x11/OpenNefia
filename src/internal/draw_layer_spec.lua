local env = require("internal.env")
local Env = require("api.Env")
local Log = require("api.Log")

local draw_layer_spec = class.class("draw_layer_spec")

function draw_layer_spec:init()
   self.layers = {}
end

function draw_layer_spec:iter()
   return next, self.layers, nil
end

function draw_layer_spec:register_draw_layer(tag, require_path, z_order, enabled)
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

function draw_layer_spec:set_draw_layer_enabled(tag, enabled)
   if not self.layers[tag] then
      error(("Layer '%s' isn't registered"):format(tag))
   end
   enabled = not not enabled
   self.layers[tag].enabled = enabled
end

return draw_layer_spec
