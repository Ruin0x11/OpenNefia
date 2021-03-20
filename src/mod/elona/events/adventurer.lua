local News = require("mod.elona.api.News")
local Event = require("api.Event")
local I18N = require("api.I18N")
local MapObject = require("api.MapObject")
local Enum = require("api.Enum")
local Map = require("api.Map")
local Chara = require("api.Chara")
local Adventurer = require("mod.elona.api.Adventurer")

local function add_news_gain_level(chara, params)
   if not chara:find_role("elona.adventurer") or not params.show_message then
      return
   end

   -- >>>>>>>> shade2/text.hsp:1323 	if type=2{ ...
   local topic = I18N.get("news.growth.title")
   local text = I18N.get("news.growth.text", chara.title, chara.name, chara.level)
   -- <<<<<<<< shade2/text.hsp:1326 		} ..

   -- >>>>>>>> shade2/calculation.hsp:52 		addNews 2,r1 ...
   News.add(text, topic)
   -- <<<<<<<< shade2/calculation.hsp:52 		addNews 2,r1 ..
end
Event.register("elona_sys.on_chara_gained_level", "Add news for adventurer level gain", add_news_gain_level)

local function cleanup_adventurer(chara)
   if not MapObject.is_map_object(chara, "base.chara")
      or not chara:find_role("elona.adventurer")
   then
      return
   end

   save.elona.staying_adventurers:unregister(chara)

   -- >>>>>>>> shade2/text.hsp:1323 	if type=2{ ...
   local topic = I18N.get("news.growth.title")
   local text = I18N.get("news.growth.text", chara.title, chara.name, chara.level)
   -- <<<<<<<< shade2/text.hsp:1326 		} ..

   -- >>>>>>>> shade2/calculation.hsp:52 		addNews 2,r1 ...
   News.add(text, topic)
   -- <<<<<<<< shade2/calculation.hsp:52 		addNews 2,r1 ..
end
Event.register("base.on_object_removed", "Clean up adventurer status", cleanup_adventurer)

local function transfer_staying_adventurers(_, params)
   -- >>>>>>>> shade2/map.hsp:1875 	repeat maxAdv,maxFollower ...
   local next_map = params.next_map

   local player = Chara.player()
   for _, adv in save.elona.staying_adventurers:do_transfer(next_map) do
      if adv:calc("is_hired") then
         adv.relation = Enum.Relation.Ally
         Map.try_place_chara(adv, player.x, player.y, next_map)
      else
         Map.try_place_chara(adv, nil, nil, next_map)
         adv.hp = adv:calc("max_hp")
         adv.mp = adv:calc("max_mp")
         adv.stamina = adv:calc("max_stamina")
      end
   end
   -- <<<<<<<< shade2/map.hsp:1892 	loop ..
end
Event.register("base.on_map_leave", "Transfer staying adventurers", transfer_staying_adventurers, { priority = 350000 })
