local Chara = require("api.Chara")
local I18N = require("api.I18N")
local Pos = require("api.Pos")

local function cardinal_direction(x1, y1, x2, y2)
   -- >>>>>>>> shade2/module.hsp:2390 #module ...
   if math.abs(x1-x2) > math.abs(y1-y2) then
      if x1 > x2 then
         return "west"
      else
         return "east"
      end
   else
      if y1 > y2 then
         return "north"
      else
         return "south"
      end
   end
   -- <<<<<<<< shade2/module.hsp:2397  ..
end

local DIR_KEYS = {
   west = "talk.npc.guard.where_is.direction.west",
   east = "talk.npc.guard.where_is.direction.east",
   north = "talk.npc.guard.where_is.direction.north",
   south = "talk.npc.guard.where_is.direction.south"
}

local function locate_chara_text(speaker, chara)
   -- >>>>>>>> shade2/chat.hsp:2967 	if chatVal>=headChatListClientGuide{ ...
   if not Chara.is_alive(chara) then
      return I18N.get("talk.npc.guard.where_is.dead", speaker)
   end
   local player = Chara.player()
   local dir = cardinal_direction(player.x, player.y, chara.x, chara.y)
   local dir_key = I18N.get(DIR_KEYS[dir])
   local dist = Pos.dist(player.x, player.y, chara.x, chara.y)

   if speaker.uid == chara.uid then
      return I18N.get("talk.npc.common.you_kidding", speaker, chara, dir_key)
   elseif dist < 6 then
      return I18N.get("talk.npc.guard.where_is.very_close", speaker, chara, dir_key)
   elseif dist < 12 then
      return I18N.get("talk.npc.guard.where_is.close", speaker, chara, dir_key)
   elseif dist < 20 then
      return I18N.get("talk.npc.guard.where_is.moderate", speaker, chara, dir_key)
   elseif dist < 35 then
      return I18N.get("talk.npc.guard.where_is.far", speaker, chara, dir_key)
   end
   return I18N.get("talk.npc.guard.where_is.very_far", speaker, chara, dir_key)
   -- <<<<<<<< shade2/chat.hsp:2983 		} ..
end

data:add {
   _type = "elona_sys.dialog",
   _id = "guard",

   nodes = {
      where_is = {
         text = function(t, state, params)
            local speaker = t.speaker
            local chara_uid = params.chara_uid
            local chara = speaker:current_map():get_object_of_type("base.chara", chara_uid)
            return locate_chara_text(t.speaker, chara)
         end,
         jump_to = "elona.default:talk"
      },
      lost_item = function(t)
         return "elona.default:talk"
      end,
   }
}
