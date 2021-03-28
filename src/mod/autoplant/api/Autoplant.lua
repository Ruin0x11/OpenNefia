local Item = require("api.Item")
local Shortcut = require("mod.elona.api.Shortcut")
local Gui = require("api.Gui")

local Autoplant = {}

function Autoplant.is_enabled()
   return not not save.autoplant.enabled
end

function Autoplant.set_enabled(enabled)
   save.autoplant.enabled = not not enabled
end

function Autoplant.toggle()
   save.autoplant.enabled = not save.autoplant.enabled

   if save.autoplant.enabled then
      Gui.mes("autoplant.command.enable")
   else
      Gui.mes("autoplant.command.disable")
   end

   Gui.refresh_hud()
end

function Autoplant.is_autoplantable(item)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:67930 				oom_seedlistmax = 0 ...
   if not Item.is_alive(item) then
      return false
   end

   if not item:has_category("elona.crop_seed") then
      return false
   end

   if item:calc("is_no_drop") then
      return false
   end

   local has_shortcut = Shortcut.iter():filter(function(i, sc) return sc.type == "item" and sc.item_id == item._id end)
   if not has_shortcut then
      return false
   end

   return true
   -- <<<<<<<< oomSEST/src/southtyris.hsp:67954 				loop ..
end

function Autoplant.find_autoplantable_seeds(chara)
   return chara:iter_inventory():filter(Autoplant.is_autoplantable):to_list()
end

return Autoplant
