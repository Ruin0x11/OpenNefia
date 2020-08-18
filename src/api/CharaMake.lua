local chara_make = require("game.chara_make")

-- Functions for interacting with the character making process. Of
-- course, they will only have an effect while character making is
-- ongoing.
-- @module CharaMake
local CharaMake = {}

CharaMake.set_caption = chara_make.set_caption
CharaMake.is_active = chara_make.is_active
CharaMake.get_in_progress_result = chara_make.get_in_progress_result

return CharaMake
