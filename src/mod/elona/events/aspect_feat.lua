local IFeatDescendable = require("mod.elona.api.aspect.feat.IFeatDescendable")
local IFeatActivatable = require("mod.elona.api.aspect.feat.IFeatActivatable")
local Event = require("api.Event")
local Aspect = require("api.Aspect")
local Gui = require("api.Gui")

local function permit_feat_actions(feat)
   if feat:iter_aspects(IFeatActivatable):length() > 0 then
      feat.can_activate = true
   end
 
   if feat:iter_aspects(IFeatDescendable):length() > 0 then
      feat.can_descend = true
   end
end
Event.register("base.on_feat_instantiated", "Permit feat actions", permit_feat_actions)

-- Queries the player for an aspect action to use if there is more than one
-- aspect on an item that fulfills a specific interface. Runs the specified
-- callback on that aspect and returns its turn result.
local function prompt_and_run_aspect(iface, name, cb_name, filter)
   filter = filter or function(aspect, obj, params, result) return true end

   return function(feat, params, result)
      local filter2 = function(aspect, obj)
         return filter(aspect, obj, params, result)
      end
      local mes = function(obj)
         Gui.mes("base:aspect._." .. name .. ".prompt", obj:build_name(1))
      end

      local aspect = Aspect.query_aspect(feat, iface, filter2, mes)

      if aspect then
         return aspect[cb_name](aspect, feat, params, result)
      else
         return "player_turn_query"
      end
   end
end

local aspect_feat_activatable = prompt_and_run_aspect(IFeatActivatable, "elona.IFeatActivatable", "on_activate")
Event.register("elona_sys.on_feat_activate", "Aspect: IFeatActivatable", aspect_feat_activatable)

local aspect_feat_descendable = prompt_and_run_aspect(IFeatDescendable, "elona.IFeatDescendable", "on_descend")
Event.register("elona_sys.on_feat_descend", "Aspect: IFeatDescendable", aspect_feat_descendable)
