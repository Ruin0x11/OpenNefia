-- I'm going off of up10096.txt for the originating variants.

local omake = {
   ["sorosu"] =            { elona_id = 401 },
   ["turusu"] =            { elona_id = 402 },
   ["hodoku"] =            { elona_id = 403 },
   ["sibaru"] =            { elona_id = 404 },
   ["nikorose"] =          { elona_id = 405 },
   ["saite"] =             { elona_id = 406 },
   ["biyaku"] =            { elona_id = 407 },
   ["sibui"] =             { elona_id = 408 },
   ["txtnamaniku"] =       { elona_id = 409 },
   ["kona"] =              { elona_id = 410 },
   ["namamen"] =           { elona_id = 411 },
   ["heibon"] =            { elona_id = 412 },
   ["txt1_2"] =            { elona_id = 413 },
   ["txt3_4"] =            { elona_id = 414 },
   ["txt5_6"] =            { elona_id = 415 },
   ["txt7_8"] =            { elona_id = 416 },
   ["9saiko"] =            { elona_id = 417 },
   ["kunren"] =            { elona_id = 418 },
   ["onaka"] =             { elona_id = 419 },
   ["hinsi"] =             { elona_id = 420 },
   ["sing"] =              { elona_id = 421 },
   ["cast"] =              { elona_id = 422 },
   ["pornobook"] =         { elona_id = 423 },
   ["pornobookdefault"] =  { elona_id = 424 },
}

local oo = {
   ["allykilled"] =        { elona_id = 425 }, -- ???
   ["allykilleddefault"] = { elona_id = 426 }, -- ???
   ["actbefore"] =         { elona_id = 427 },
   ["actafter"] =          { elona_id = 428 },
   ["milkcurse"] =         { elona_id = 429 },
   ["milk"] =              { elona_id = 430 },
   ["sakecurse"] =         { elona_id = 431 },
   ["sake"] =              { elona_id = 432 },
   ["yopparai"] =          { elona_id = 433 },
}

local mma = {
   ["hurt1"] =             { elona_id = 107 },
   ["hurt2"] =             { elona_id = 108 },
   ["hurt3"] =             { elona_id = 109 },
}

local oom = {
   ["milk2"] =             { elona_id = 949 },
   ["milkcurse2"] =        { elona_id = 950 },
   ["caststyle2"] =        { elona_id = 965 },
   ["swarm"] =             { elona_id = 966 },
   ["kisei"] =             { elona_id = 967 },
   ["caststyle"] =         { elona_id = 968 },
   ["uzimushi"] =          { elona_id = 969 },
   ["fished"] =            { elona_id = 951 },
   ["egg"] =               { elona_id = 952 },
   ["jerky"] =             { elona_id = 953 },
   ["meat"] =              { elona_id = 954 },
   ["drunkkaramare"] =     { elona_id = 955 },
   ["drunkkarami"] =       { elona_id = 956 },
   ["food1"] =             { elona_id = 957 },
   ["food2"] =             { elona_id = 958 },
   ["awake"] =             { elona_id = 959 },
   ["night"] =             { elona_id = 960 },
   ["enchantelem"] =       { elona_id = 961 },
   ["godskill"] =          { elona_id = 962 },
   ["midare"] =            { elona_id = 963 },
   ["kuyasii2"] =          { elona_id = 964 },
   ["toketa"] =            { elona_id = 970 },
   ["tobidasi"] =          { elona_id = 971 },
   ["umare"] =             { elona_id = 972 },
   ["parasite"] =          { elona_id = 973 },
   ["batou"] =             { elona_id = 974 },
   ["bravo"] =             { elona_id = 975 },
   ["throwrock"] =         { elona_id = 976 },
   ["urusai"] =            { elona_id = 977 },
   ["akita"] =             { elona_id = 978 },
   ["layhand"] =           { elona_id = 979 },
   ["karadake"] =          { elona_id = 980 },
   ["toriage"] =           { elona_id = 981 },
   ["yubikubi"] =          { elona_id = 982 },
   ["omiyage"] =           { elona_id = 983 },
   ["tyohazusu"] =         { elona_id = 984 },
   ["snaguru"] =           { elona_id = 985 },
   ["kya"] =               { elona_id = 989 },
   ["sand"] =              { elona_id = 993 },
   ["titi"] =              { elona_id = 994 },
   ["noru"] =              { elona_id = 996 },
   ["oriru"] =             { elona_id = 997 },
   ["jigo"] =              { elona_id = 998 },
   ["kuyasii"] =           { elona_id = 999 },
   ["abuse"] =             { elona_id = 1000 },
   ["marriage"] =          { elona_id = 1001 },
   ["anata"] =             { elona_id = 1002 },
   ["iyayo"] =             { elona_id = 1003 },
   ["nakanaka"] =          { elona_id = 1004 },
   ["ikuyo"] =             { elona_id = 1005 },
   ["kiyameru"] =          { elona_id = 1006 },
   ["pbou"] =              { elona_id = 1007 },
   ["exhiya"] =            { elona_id = 1008 },
   ["exthank"] =           { elona_id = 1009 },
   ["goei"] =              { elona_id = 1010 },
   ["yatou"] =             { elona_id = 1011 },
   ["hihiya"] =            { elona_id = 1012 },
   ["umaku"] =             { elona_id = 1013 },
   ["tikara"] =            { elona_id = 1014 },
   ["0free"] =             { elona_id = 1015 },
   ["okoto"] =             { elona_id = 1016 },
   ["yanwari"] =           { elona_id = 1017 },
   ["kodukuri"] =          { elona_id = 1018 },
   ["housecooking"] =      { elona_id = 1019 },
   ["housecookingyes"] =   { elona_id = 1020 },
   ["housecookingno"] =    { elona_id = 1021 },
   ["maid2"] =             { elona_id = 1022 },
   ["npcpos1"] =           { elona_id = 1023 },
   ["npcpos2"] =           { elona_id = 1024 },
   ["npcpos3"] =           { elona_id = 1025 },
   ["npcpos4"] =           { elona_id = 1026 },
   ["npcpos0"] =           { elona_id = 1027 },
}

local oomsest = {
   ["PutAwayEngagementAccessories"] = { elona_id = 1028 },
   ["DairyProduct"] =                 { elona_id = 1029 },
   ["maid3"] =                        { elona_id = 1100 },
   ["maid4"] =                        { elona_id = 1101 },
   ["homemaid"] =                     { elona_id = 1102 },
}

local function make_talk_events(evs, variant)
   local map = function(ev,t)
      local _id = t._id or string.to_snake_case(ev)
      return {
         _id = _id,
         variant_ids = {
            [variant] = t.elona_id
         },
         variant_txt_ids = {
            [variant] = ("txt%s"):format(_id)
         }
      }
   end
   return fun.iter_pairs(evs):map(map):to_list()
end

data:add_multi("base.talk_event", make_talk_events(omake, "omake"))
data:add_multi("base.talk_event", make_talk_events(oo, "oo"))
data:add_multi("base.talk_event", make_talk_events(mma, "mma"))
data:add_multi("base.talk_event", make_talk_events(oom, "oom"))
data:add_multi("base.talk_event", make_talk_events(oomsest, "oomsest"))
