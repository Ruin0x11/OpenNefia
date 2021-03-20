local World = require("api.World")
local Gui = require("api.Gui")

local News = {}

function News.iter()
   return fun.wrap(save.elona.news_buffer:iter())
end

local function add_topic(topic, buff)
   -- >>>>>>>> shade2/text.hsp:1309 #deffunc addNewsTopic str s,str s2 ...
   local date = World.date()

   local text = ("<color=#0000C8> %d/%d/%d h%d %s"):format(date.year, date.month, date.day, date.hour, topic)
   buff:push(text)
   -- <<<<<<<< shade2/text.hsp:1311 	return ..
end

function News.add(text, topic, no_message)
   local buff = save.elona.news_buffer
   if topic then
      add_topic(topic, buff)
   end

   -- >>>>>>>> shade2/text.hsp:1304 	n=s : if putTxt : txtEf coFresh : txt "[News] "+n ...
   if not no_message then
      Gui.mes_c(text, "Fresh")
   end

   buff:push(text)
   -- <<<<<<<< shade2/text.hsp:1307 	return ..
end

return News
