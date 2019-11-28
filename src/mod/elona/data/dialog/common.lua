local Chara = require("api.Chara")
local Map = require("api.Map")
local Gui = require("api.Gui")
local I18N = require("api.I18N")

local common = {}

function common.create_downstairs(x, y, dungeon_level)
   error("downstairs")
end

function common.show_journal_update_message()
   Gui.play_sound("base.write1");
   Gui.mes_c("quest.journal_updated", "Green");
end

function common.quest_completed()
   Gui.mes("quest.completed", "Green")
   Gui.play_sound("base.complete1")
   Gui.mes("common.something_is_put_on_the_ground")
   common.show_journal_update_message()
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
