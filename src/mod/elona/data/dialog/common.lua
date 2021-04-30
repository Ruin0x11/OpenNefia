local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Feat = require("api.Feat")
local Area = require("api.Area")

local common = {}

function common.create_downstairs(x, y, floor, map)
   local downstairs = assert(Feat.create("elona.stairs_down", x, y, {force=true}, map))
   local area = assert(Area.for_map(map))
   downstairs.params.area_uid = area.uid
   downstairs.params.area_floor = floor
end

function common.quest_completed()
   Gui.mes("quest.completed", "Green")
   Gui.play_sound("base.complete1")
   Gui.mes("common.something_is_put_on_the_ground")
   Sidequest.update_journal()
end

function common.args_name()
   return {Chara.player().name}
end

function common.args_title()
   return {Chara.player().title}
end

function common.args_speaker(t)
   return {t.speaker}
end

return common
