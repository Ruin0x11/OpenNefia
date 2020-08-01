local Event = require("api.Event")
local DateTime = require("api.DateTime")
local uid_tracker = require("internal.uid_tracker")
local Rand = require("api.Rand")
local save = require("internal.global.save")

local function init_save()
   local s = save.base
   s.date = DateTime:new(517, 8, 12, 16, 10, 0)
   s.play_time = 0
   s.play_turns = 0
   s.play_days = 0
   s.player = nil
   s.allies = {}
   s.uids = uid_tracker:new()
   s.map_uids = uid_tracker:new()
   s.area_uids = uid_tracker:new()
   s.random_seed = Rand.rnd(800) + 2
   s.shadow = 70
   s.has_light_source = false
   s.deepest_level = 0
   s.map_registry = {}
   s.containers = {}
   s.tracked_skill_ids = {}
   s.bones = {}
   s.total_killed = 0
   s.total_deaths = 0
   s.areas = {}
   s.travel_distance = 0
   s.travel_date = 0
   s.travel_date = 0
   s.travel_last_town_name = ""
end

Event.register("base.on_init_save", "Init save (base)", init_save, {priority = 0})
