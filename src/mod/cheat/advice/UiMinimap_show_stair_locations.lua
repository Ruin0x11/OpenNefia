local Advice = require("api.Advice")
local Extend = require("api.Extend")
local IFeatLockedHatch = require("mod.elona.api.aspect.feat.IFeatLockedHatch")

local UiMinimap_show_stair_locations = {}

UiMinimap_show_stair_locations.after = {}

function UiMinimap_show_stair_locations.after:init(...)
   local ext = Extend.get_or_create(self, "cheat")

   ext.stair_locations = {}
end

function UiMinimap_show_stair_locations.after:refresh_visible(map)
   if not self.tile_batch or map == nil then
      return
   end

   local ext = Extend.get(self, "cheat")
   local locs = {}

   for _, feat in map:iter_feats() do
      if feat._id == "elona.stairs_up" then
         locs[#locs+1] = { type = "up", x = feat.x, y = feat.y }
      elseif feat._id == "elona.stairs_down" or feat:get_aspect(IFeatLockedHatch) then
         locs[#locs+1] = { type = "down", x = feat.x, y = feat.y }
      end
   end

   ext.stair_locations = locs
end

function UiMinimap_show_stair_locations.after:draw(...)
   if not config.cheat.show_stair_locations then
      return
   end

   local ext = Extend.get(self, "cheat")

   for _, loc in ipairs(ext.stair_locations) do
      local x = math.clamp(loc.x * self.tw, 2, self.width - 8)
      local y = math.clamp(loc.y * self.th, 2, self.height - 8)
      self.t.base.minimap_marker_player:draw(self.x + x, self.y + y)
   end
end

for where, t in pairs(UiMinimap_show_stair_locations) do
   for fn_name, fn in pairs(t) do
      Advice.add(where, "api.gui.hud.UiMinimap", fn_name, ("Show stair locations: %s()"):format(fn_name), fn)
   end
end
