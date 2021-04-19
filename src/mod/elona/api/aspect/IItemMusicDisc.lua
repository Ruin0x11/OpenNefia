local IAspect = require("api.IAspect")
local ISortable = require("mod.elona.api.aspect.ISortable")
local IItemLocalizableExtra = require("mod.elona.api.aspect.IItemLocalizableExtra")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local I18N = require("api.I18N")
local Gui = require("api.Gui")

local IItemMusicDisc = class.interface("IItemMusicDisc", {
                                          music_id = "string",
                                                         },
                                       {
                                          IAspect,
                                          ISortable,
                                          IItemUseable,
                                          IItemLocalizableExtra
                                       })

IItemMusicDisc.default_impl = "mod.elona.api.aspect.ItemMusicDiscAspect"

function IItemMusicDisc:localize_action()
   return "base:aspect._.elona.IItemMusicDisc.action_name"
end

function IItemMusicDisc:sort(other)
   return self.music_id < other.music_id
end

function IItemMusicDisc:localize_extra(s, item)
   local info
   local music_id = self:calc(item, "music_id")
   local music = data["base.music"][music_id]
   if music then
      local ext = data["base.music"]:ext(music_id, "elona.music_disc")
      local name = I18N.localize_optional("base.music", music_id, "name")
      if name then
         info = (" \"%s\""):format(name)
      elseif ext and ext.music_number then
         info = tostring(ext.music_number)
      elseif music.elona_id then
         if music.elona_id > 50 then
            info = tostring(music.elona_id - 50 - 1)
         else
            info = "???"
         end
      else
         info = (" \"%s\""):format(music_id)
      end
   else
      info = "???"
   end
   return ("%s <BGM%s>"):format(s, info)
end

function IItemMusicDisc:on_use(item, params)
   -- >>>>>>>> shade2/action.hsp:1920 	case effMusicPlayer ...
   Gui.mes("action.use.music_disc.play", item:build_name(1))
   local music_id = self:calc(item, "music_id")
   local map = item:containing_map()
   if map then
      map.music = music_id
   end
   Gui.play_music(music_id)
   -- <<<<<<<< shade2/action.hsp:1924 	swbreak ..
end

return IItemMusicDisc
