local IItemMusicDisc = require("mod.elona.api.aspect.IItemMusicDisc")
local Rand = require("api.Rand")

local ItemMusicDiscAspect = class.class("ItemMusicDiscAspect", { IItemMusicDisc })

local function can_generate(music)
   return data["base.music"]:ext(music._id, "elona.music_disc").can_randomly_generate
end

function ItemMusicDiscAspect:init(item, params)
   if params.music_id then
      data["base.music"]:ensure(params.music_id)
      self.music_id = params.music_id
   else
      self.music_id = Rand.choice(data["base.music"]:iter():filter(can_generate))._id
   end
end

return ItemMusicDiscAspect
