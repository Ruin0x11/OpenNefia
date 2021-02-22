local Const = require("api.Const")
local Event = require("api.Event")
local DateTime = require("api.DateTime")
local UidTracker = require("api.UidTracker")
local Rand = require("api.Rand")
local save = require("internal.global.save")
local parties = require("internal.parties")

local function init_save()
   local s = save.base
   s.date = DateTime:new(Const.INITIAL_YEAR, Const.INITIAL_MONTH, Const.INITIAL_DAY, 1, 10)
   s.play_time = 0
   s.play_turns = 0
   s.play_days = 0
   s.player = nil
   s.parties = parties:new()
   s.uids = UidTracker:new()
   s.map_uids = UidTracker:new()
   s.area_uids = UidTracker:new()
   s.random_seed = Rand.rnd(800) + 2
   s.shadow = 70
   s.has_light_source = false
   s.deepest_level = 0
   s.containers = {}
   s.tracked_skill_ids = {}
   s.bones = {}
   s.total_killed = 0
   s.total_deaths = 0
   s.areas = table.set {}
   s.unique_areas = table.set {}
   s.travel_distance = 0
   s.travel_date = 0
   s.travel_date = 0
   s.travel_last_town_name = ""
   s.is_first_turn = false
end

Event.register("base.on_init_save", "Init save (base)", init_save, {priority = 0})
