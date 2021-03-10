local Event = require("api.Event")
local Feat = require("api.Feat")

local actions = {
   "bash",                 -- on_bash,                 can_bash,                 elona_sys.on_feat_bash
   "activate",             -- on_activate,             can_activate,             elona_sys.on_feat_activate
   "search",               -- on_search,               can_search,               elona_sys.on_feat_search
   "search_from_distance", -- on_search_from_distance, can_search_from_distance, elona_sys.on_feat_search_from_distance
   "open",                 -- on_open,                 can_open,                 elona_sys.on_feat_open
   "close",                -- on_close,                can_close,                elona_sys.on_feat_close
   "descend",              -- on_descend,              can_descend,              elona_sys.on_feat_descend
   "ascend",               -- on_ascend,               can_ascend,               elona_sys.on_feat_ascend
   "bumped_into",          -- on_bumped_into,          can_bumped_into,          elona_sys.on_feat_bumped_into
   "stepped_on",           -- on_stepped_on,           can_stepped_on,           elona_sys.on_feat_stepped_on
}

local function connect_feat_events(obj)
   if obj._type ~= "base.feat" then
      return
   end

   local feat = obj

   for _, action in ipairs(actions) do
      local event_id = ("elona_sys.on_feat_%s"):format(action)
      local callback_name = ("on_%s"):format(action)
      local event_name = ("Feat prototype %s handler"):format(callback_name)
      local flag_name = ("can_%s"):format(action)

      -- If a handler is left over from previous instantiation
      if feat:has_event_handler(event_id, event_name) then
         feat:disconnect_self(event_id, event_name)
      end

      if feat.proto[callback_name] then
         feat:connect_self(event_id, event_name, feat.proto[callback_name])
      end

      if feat:has_event_handler(event_id) then
         feat[flag_name] = true
      else
         feat[flag_name] = nil
      end
   end
end
Event.register("base.on_object_prototype_changed", "Connect feat events", connect_feat_events)

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

local function feat_stepped_on_handler(chara, p, result)
   for _, feat in Feat.at(p.x, p.y, chara:current_map()) do
      feat:emit("elona_sys.on_feat_stepped_on", {chara=chara})
   end

   return result
end
Event.register("base.on_chara_moved", "Feat stepped on behavior", feat_stepped_on_handler)
