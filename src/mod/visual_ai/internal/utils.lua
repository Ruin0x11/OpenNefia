local utils = {}
local I18N = require("api.I18N")

local COMPARATORS = {
   ["<"]  = function(a, b) return a <  b end,
   ["<="] = function(a, b) return a <= b end,
   ["=="] = function(a, b) return a == b end,
   [">="] = function(a, b) return a >= b end,
   [">"]  = function(a, b) return a >  b end,
}

function utils.compare(a, comp, b)
   local comparator = COMPARATORS[comp]
   if comparator == nil then
      error("unknown comparator ".. tostring(comp))
   end
   return comparator(a, b)
end

function utils.get_default_var_value(var)
   assert(type(var) == "table")

   local ty = var.type

   if ty == "comparator" then
      return "<"
   elseif ty == "number" or ty == "integer" then
      return var.max_value or var.min_value or 0
   else
      error("unknown block variable type ".. tostring(ty))
   end
end

function utils.get_default_vars(vars)
   if vars == nil then
      return {}
   end

   local result = {}
   for k, var in pairs(vars) do
      local value = utils.get_default_var_value(var)
      result[k] = assert(value)
   end
   return result
end

local DEFAULT_ICONS = {
   condition = "visual_ai.icon_down_right",
   target = "visual_ai.icon_figurine",
   action = "visual_ai.icon_flag",
}

function utils.get_block_color(proto, t)
   local color
   if type(proto.color) == "string" then
      color = t[proto.color]
   elseif type(proto.color) == "table" then
      color = proto.color
   else
      color = t.visual_ai[("color_block_" .. proto.type)]
   end
   assert(color and color[1])
   return color
end

function utils.get_block_icon(proto, t)
   local icon
   if proto.icon then
      icon = t[proto.icon]
   else
      local default = DEFAULT_ICONS[proto.type]
      if default then
         icon = t[default]
      end
   end
   assert(icon)
   return icon
end

function utils.get_block_text(proto, vars)
   local text
   if proto.format_name then
      text = proto.format_name(proto, vars)
      assert(type(text) == "string")
   else
      text = I18N.get("visual_ai.block." .. proto._id .. ".name")
   end
   return text
end

return utils
