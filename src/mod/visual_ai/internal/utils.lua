local I18N = require("api.I18N")
local Config = require("api.Config")

local utils = {}

local COMPARATORS = {
   ["<"]  = function(a, b) return a <  b end,
   ["<="] = function(a, b) return a <= b end,
   ["=="] = function(a, b) return a == b end,
   [">="] = function(a, b) return a >= b end,
   [">"]  = function(a, b) return a >  b end,
}

utils.vars = {
   comparator = { type = "enum", choices = { "<", "<=", "==", ">=", ">" } },
   comparator_partial = { type = "enum", choices = { "<", ">" } },
   known_skill ={
      type = "data_id",
      data_type = "base.skill",
      filter = function(skill)
         local chara = save.visual_ai.editing_chara
         if chara == nil then
            return false
         end
         return data["base.skill"]:ensure(skill).type == "spell" and chara:has_skill(skill)
      end,
      formatter = function(_id, skill_id)
         if skill_id == "none" then
            return "<none>"
         else
            return I18N.localize("base.skill", skill_id, "name")
         end
      end
   }
}

function utils.compare(a, comp, b)
   local comparator = COMPARATORS[comp]
   if comparator == nil then
      error("unknown comparator ".. tostring(comp))
   end
   return comparator(a, b)
end

function utils.get_default_vars(vars)
   if vars == nil then
      return {}
   end

   local result = {}
   for k, var in pairs(vars) do
      local _ok, value = assert(Config.get_default_option(var))
      result[k] = assert(value)
   end
   return result
end

local DEFAULT_ICONS = {
   condition = "visual_ai.icon_down_right",
   target = "visual_ai.icon_singleplayer",
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

function utils.is_block_terminal(block)
   if block.proto.type == "action" or block.proto.type == "special" then
      return block.proto.is_terminal
   end
   return false
end

function utils.make_block(proto_id)
   local proto = data["visual_ai.block"]:ensure(proto_id)

   local vars = utils.get_default_vars(proto.vars)

   return {
      _id = proto_id,
      proto = proto,
      vars = vars
   }
end

function utils.hp_mp_sp_var(kind)
   local max_var
   if kind == "mp" then
      max_var = "max_mp"
   elseif kind == "stamina" then
      max_var = "max_stamina"
   else
      max_var = "max_hp"
   end
   return max_var
end

return utils
