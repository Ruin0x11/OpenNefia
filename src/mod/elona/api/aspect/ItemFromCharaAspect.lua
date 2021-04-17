local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")

local ItemFromCharaAspect = class.class("ItemFromCharaAspect", IItemFromChara)

function ItemFromCharaAspect:init(item, params)
   self.chara_id = (params.chara and params.chara._id) or params.chara_id or nil
end

return ItemFromCharaAspect
