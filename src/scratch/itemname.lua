local Item = require("api.Item")
local Itemname = require("mod.elona.api.Itemname")
local I18N = require("api.I18N")
local Enum = require("api.Enum")

if not field.is_active then lo() end

if I18N.language() ~= "en" then
   I18N.switch_language("en")
end

local function name(id)
   local i = Item.find(id) or Item.create(id)
   i.quality = Enum.Quality.God

   i.identify_state = "unidentified"
   print("== unident ", Itemname.en(i, nil, true))

   i.identify_state = "partly"
   print("== partly  ", Itemname.en(i, nil, true))

   i.identify_state = "almost"
   print("== almost  ", Itemname.en(i, nil, true))

   i.identify_state = "completely"
   print("== completely", Itemname.en(i, nil, true))
end

name("elona.dagger")
name("elona.lemon")
name("elona.blood_moon")
