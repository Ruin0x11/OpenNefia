local Event = require("api.Event")
local Feat = require("api.Feat")
local Gui = require("api.Gui")

-- Create event handlers to call the function callbacks with these names when
-- the corresponding event is triggered.
local feat_events = {
   on_bash = "elona_sys.on_bash",
   on_activate = "elona_sys.on_feat_activate",
   on_search = "elona_sys.on_feat_search",
   on_open = "elona_sys.on_feat_open",
   on_close = "elona_sys.on_feat_close",
   on_descend = "elona_sys.on_feat_descend",
   on_ascend = "elona_sys.on_feat_ascend",
   on_bumped_into = "elona_sys.on_feat_bumped_into",
   on_stepped_on = "elona_sys.on_feat_stepped_on",
}

for cb_name, event_id in pairs(feat_events) do
   local name = ("Feat prototype %s handler"):format(cb_name)
   local handler = function(feat, params, result)
      if feat.proto[cb_name] then
         result = feat.proto[cb_name](feat, params, result) or result
      end
      return result
   end
   Event.register(event_id, name, handler, { priority = 100000 })
end

local IFeat = require("api.feat.IFeat")
Event.register("base.on_hotload_object", "reload events for feat", function(obj)
                  if class.is_an(IFeat, obj) then
                     obj:instantiate()
                  end
end)

local function feat_bumped_into_handler(chara, p, result)
   for _, feat in Feat.at(p.x, p.y, chara:current_map()) do
      if feat:calc("is_solid") then
         feat:emit("elona_sys.on_feat_bumped_into", {chara=chara})
         result.blocked = true
      end
   end

   return result
end
Event.register("base.before_chara_moved", "Feat bumped into behavior", feat_bumped_into_handler)

local function proc_confusion_message(chara)
   if chara:is_player() and chara:has_effect("elona.confusion") then
      Gui.mes_duplicate()
      Gui.mes("action.move.confused")
   end
end
Event.register("base.before_chara_moved", "Proc confusion message", proc_confusion_message, { priority = 200000 })

local function feat_stepped_on_handler(chara, p, result)
   for _, feat in Feat.at(p.x, p.y, chara:current_map()) do
      feat:emit("elona_sys.on_feat_stepped_on", {chara=chara})
   end

   return result
end
Event.register("base.on_chara_moved", "Feat stepped on behavior", feat_stepped_on_handler)
