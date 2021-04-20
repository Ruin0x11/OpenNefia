local events = {
   ["Night"] =         { elona_id = 107 },
   ["Insult"] =        { elona_id = 108 },
   ["Kiss"] =          { elona_id = 109 },
   ["Choco"] =         { elona_id = 110 },
   ["Discipline"] =    { elona_id = 111 },
   ["DisciplineOff"] = { elona_id = 112 },
   ["DisciplineEat"] = { elona_id = 113 },
   ["Charge"] =        { elona_id = 114 },
   ["Kizuna"] =        { elona_id = 115 },
   ["ChargeS"] =       { elona_id = 116 },
   ["ChargeA"] =       { elona_id = 117 },
   ["Nade"] =          { elona_id = 118 },
   ["Hug"] =           { elona_id = 119 },
   ["Special"] =       { elona_id = 120 },
   ["MidNight"] =      { elona_id = 121, _id = "midnight" },
   ["Insult2"] =       { elona_id = 123 },
   ["Discipline2"] =   { elona_id = 122 },
   ["RideOff"] =       { elona_id = 124 },
   ["RideOffPC"] =     { elona_id = 125 },
   ["RideOn"] =        { elona_id = 126 },
   ["RideOnPC"] =      { elona_id = 127 },
   ["FawnOn"] =        { elona_id = 128 },
   ["Limit"] =         { elona_id = 129 },
   ["Bfast"] =         { elona_id = 130, _id = "breakfast" },
   ["Material"] =      { elona_id = 131 },
   ["Multiple"] =      { elona_id = 132, _id = "overray" },
   ["Drain"] =         { elona_id = 133 },
   ["Create"] =        { elona_id = 134 },
   ["EXAct"] =         { elona_id = 125 },
   ["EXReact"] =       { elona_id = 136 },
   ["DialogB"] =       { elona_id = 137, _id = "evochat_b" },
   ["DialogE"] =       { elona_id = 138, _id = "evochat_e" },
   ["DialogF"] =       { elona_id = 139, _id = "evochat_f" },
   ["DialogH"] =       { elona_id = 140, _id = "evochat_h" },
   ["Meal"] =          { elona_id = 141 },
   ["Shift"] =         { elona_id = 142 },
   ["Btalk"] =         { elona_id = 143, _id = "talk_skill" },
}

local function make_talk_events(evs)
   local map = function(ev,t)
      local _id = t._id or string.to_snake_case(ev)
      return {
         _id = _id,
         variant_ids = {
            plus = t.elona_id
         },
         variant_txt_ids = {
            plus = ("txt%s"):format(_id)
         }
      }
   end
   return fun.iter_pairs(evs):map(map):to_list()
end

data:add_multi("base.talk_event", make_talk_events(events))
