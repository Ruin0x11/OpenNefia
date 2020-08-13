local Item = require("api.Item")
local Itemname = require("mod.elona.api.Itemname")
local I18N = require("api.I18N")
local Enum = require("api.Enum")

if not field.is_active then lo() end

if I18N.language_id() ~= "base.english" then
   I18N.switch_language("base.english")
end

local function name(id)
   local i = Item.find(id) or Item.create(id)
   i.quality = Enum.Quality.God

   i.identify_state = Enum.IdentifyState.None
   print("== unident ", Itemname.build_name(i, nil, true))

   i.identify_state = Enum.IdentifyState.Name
   print("== partly  ", Itemname.build_name(i, nil, true))

   i.identify_state = Enum.IdentifyState.Quality
   print("== almost  ", Itemname.build_name(i, nil, true))

   i.identify_state = Enum.IdentifyState.Full
   print("== completely", Itemname.build_name(i, nil, true))
end

name("elona.dagger")
name("elona.lemon")
name("elona.blood_moon")
