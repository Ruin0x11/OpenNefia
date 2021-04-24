local IFeatLockedDoor = require("mod.elona.api.aspect.feat.IFeatLockedDoor")

local function gen_locked(floor, main_quest_flag, on_unlock_text)
   data:add {
      _type = "base.feat",
      _id = ("locked_door_floor_%d"):format(floor),

      _ext = {
         [IFeatLockedDoor] = {
            sidequest_id = "elona.main_quest",
            sidequest_flag = main_quest_flag,
            on_unlock_text = on_unlock_text,
            feat_id = "elona.stairs_down",
         }
      }
   }
end

-- >>>>>>>> shade2/action.hsp:821 		if gLevel=3 :if flagMain>=65	: f=true ...
gen_locked(3, 65)
gen_locked(17, 115)
gen_locked(25, 125)
gen_locked(44, 125, "action.use_stairs.unlock.stones")
-- <<<<<<<< shade2/action.hsp:824 		if gLevel=44:if flagMain>=125	: f=true ..
