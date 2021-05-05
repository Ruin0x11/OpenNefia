local env = require("internal.env")
local IAspect = require("api.IAspect")
local aspect_state = require("internal.global.aspect_state")
local IAspectModdable = require("api.IAspectModdable")
local Log = require("api.Log")

local Aspect = {}

function Aspect.get_default_impl(iface)
   if type(iface) == "string" then
      iface = env.safe_require(iface)
   end
   class.assert_implements(IAspect, iface)
   assert(class.is_interface(iface))

   local impl = aspect_state.default_impls[iface.__name]
   if impl == nil and iface.default_impl then
      Aspect.set_default_impl(iface, iface.default_impl)
   end

   return aspect_state.default_impls[iface.__name] or nil
end

function Aspect.set_default_impl(iface, impl)
   if type(iface) == "string" then
      iface = env.safe_require(iface)
   end
   class.assert_implements(IAspect, iface)
   assert(class.is_interface(iface))

   if type(impl) == "string" then
      impl = env.safe_require(impl)
   end
   class.assert_implements(iface, impl)
   assert(class.is_class(impl))

   aspect_state.default_impls[iface.__name] = impl
end

function Aspect.new_default(iface, obj, params)
   return Aspect.get_default_impl(iface):new(obj, params)
end

local function build_default_aspect(obj, iface, params)
   local klass
   if params._impl then
      class.assert_implements(iface, params._impl)
      klass = params._impl
      params._impl = nil
   else
      klass = Aspect.get_default_impl(iface)
   end
   local aspect = klass:new(obj, params)
   IAspectModdable.init(aspect)
   return aspect
end

local function is_aspect(v)
   return class.is_interface(v) and class.is_an(IAspect, v)
end

-- Builds the aspects indicated in a map object's _ext table on its prototype.
function Aspect.build_defaults_for(obj, aspect_opts)
   local _ext = obj.proto._ext
   if not _ext then
      return {}
   end

   local result = {}
   local seen = table.set {}

   for k, v in pairs(_ext) do
      if type(k) == "number" and is_aspect(v) then
         seen[v] = true
         result[v] = build_default_aspect(obj, v, (aspect_opts and aspect_opts[v]) or {})
      elseif is_aspect(k) then
         seen[k] = true
         local _params = (aspect_opts and aspect_opts[k]) or {}
         if type(v) == "table" then
            _params = table.merge_ex(table.deepcopy(v), _params)

            -- HACK it shouldn't be possible to deepcopy class tables
            if v._impl then
               _params._impl = v._impl
            end
         end
         result[k] = build_default_aspect(obj, k, _params)
      end
   end

   if aspect_opts then
      for iface, _opts in pairs(aspect_opts) do
         if is_aspect(iface) and not seen[iface] then
            Log.error("Aspect arguments recieved for %s, but prototype does not declare that aspect in its _ext table.", iface)
         end
      end
   end

   return result
end

-- Queries the player for an aspect action to use if there is more than one
-- aspect on an item that fulfills a specific interface.
function Aspect.query_aspect(obj, iface, filter, mes_cb)
   filter = filter or fun.op.truth
   local aspects = obj:iter_aspects(iface):filter(function(a) return filter(a, obj) end):to_list()

   if #aspects == 0 then
      return nil
   elseif #aspects == 1 then
      return aspects[1]
   else
      local map = function(aspect)
         return aspect:localize_action(obj, iface)
      end

      local choices = fun.iter(aspects):map(map):to_list()

      -- TODO disambiguate serialization ID and __name for classes
      if mes_cb then
         mes_cb(obj, iface)
      end
      local Prompt = require("api.gui.Prompt")
      local result, canceled = Prompt:new(choices):query()

      if canceled then
         return nil
      end

      return aspects[result.index]
   end
end

return Aspect
