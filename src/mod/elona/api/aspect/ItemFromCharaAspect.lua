local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")

local ItemFromCharaAspect = class.class("ItemFromCharaAspect", IItemFromChara)

function ItemFromCharaAspect:init(item, params)
   if params.chara then
      self.chara_id = params.chara._id
   end

   self.chara_id = params.chara_id or self.chara_id
end

return ItemFromCharaAspect
