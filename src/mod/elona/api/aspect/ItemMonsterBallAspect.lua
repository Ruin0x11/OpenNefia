local IItemMonsterBall = require("mod.elona.api.aspect.IItemMonsterBall")

local ItemMonsterBallAspect = class.class("ItemMonsterBallAspect", { IItemMonsterBall })

function ItemMonsterBallAspect:init(item, params, gen_params)
   -- >>>>>>>> shade2/item.hsp:665 	if iId(ci)=idMonsterBall{ ..
   self.chara_id = params.chara_id or nil
   self.chara_level = params.chara_level or nil
   self.max_level = params.max_level or 0
   -- <<<<<<<< shade2/item.hsp:668 		} ..
end

return ItemMonsterBallAspect
