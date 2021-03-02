local Const = {}

--- Number of hours before killed citizens are respawned.
Const.CITIZEN_RESPAWN_HOURS = 48

Const.MAX_CHARAS_ALLY = 16
Const.MAX_CHARAS_ADVENTURER = 40
Const.MAX_CHARAS_SAVED = Const.MAX_CHARAS_ALLY + Const.MAX_CHARAS_ADVENTURER
Const.MAX_CHARAS = 245
Const.MAX_CHARAS_OTHER = Const.MAX_CHARAS - Const.MAX_CHARAS_SAVED

Const.KARMA_BAD = -30
Const.KARMA_GOOD = 20

Const.MAP_RENEW_MAJOR_HOURS = 120
Const.MAP_RENEW_MINOR_HOURS = 24

Const.RESIST_GRADE = 50

Const.MAX_ENCHANTMENTS = 15

Const.WEAPON_WEIGHT_LIGHT = 1500
Const.WEAPON_WEIGHT_HEAVY = 4000

Const.FATIGUE_HEAVY = 0
Const.FATIGUE_MODERATE = 25
Const.FATIGUE_LIGHT = 50

Const.MAX_SKILL_LEVEL = 2000
Const.MAX_SKILL_POTENTIAL = 400
Const.MAX_SKILL_EXPERIENCE = 1000
Const.POTENTIAL_DECAY_RATE = 0.9

-- >>>>>>>> shade2/init.hsp:88 	#define global initYear		517 ..
Const.INITIAL_YEAR = 517
Const.INITIAL_MONTH = 8
Const.INITIAL_DAY = 12
-- <<<<<<<< shade2/init.hsp:90 	#define global initDay		12 ..

Const.SKILL_POINT_EXPERIENCE_GAIN = 400

-- >>>>>>>> elona122/shade2/init.hsp:19 	#define global defImpEnemy	0 ..
Const.IMPRESSION_ENEMY = 0
Const.IMPRESSION_HATE = 25
Const.IMPRESSION_NORMAL = 50
Const.IMPRESSION_PARTY = 53
Const.IMPRESSION_AMIABLE = 75
Const.IMPRESSION_FRIEND = 100
Const.IMPRESSION_FELLOW = 150
Const.IMPRESSION_MARRY = 200
Const.IMPRESSION_SOULMATE = 300
-- <<<<<<<< elona122/shade2/init.hsp:27 	#define global defImpSoulMate	300 ..

Const.MAP_MINOR_RENEW_STEP_HOURS = 24
Const.PLANT_GROWTH_DAYS = 4

Const.AI_RANGED_ATTACK_THRESHOLD = 6
Const.AI_THROWING_ATTACK_THRESHOLD = 8

-- >>>>>>>> shade2/init.hsp:124 	#define global conSickHeavy	30 ...
Const.CON_SICK_HEAVY      = 30
Const.CON_POISON_HEAVY    = 30
Const.CON_SLEEP_HEAVY     = 30

Const.CON_DIM_HEAVY       = 60
Const.CON_DIM_MODERATE    = 30

Const.CON_ANGRY_HEAVY     = 30

Const.CON_BLEED_HEAVY     = 20
Const.CON_BLEED_MODERATE  = 10

Const.CON_INSANE_HEAVY    = 50
Const.CON_INSANE_MODERATE = 25

Const.CON_DRUNK_HEAVY     = 45
-- <<<<<<<< shade2/init.hsp:139 	#define global conDrunkHeavy	45 ...

-- >>>>>>>> shade2/init.hsp:39 	#define global defArmorHeavy	35000 ...
Const.ARMOR_WEIGHT_CLASS_HEAVY = 35000
Const.ARMOR_WEIGHT_CLASS_MEDIUM = 15000
-- <<<<<<<< shade2/init.hsp:40 	#define global defArmorMedium	15000 ..

-- >>>>>>>> shade2/item_data.hsp:656 	#define global rangeEgoTitleSp	30000 ...
Const.RANDOM_ITEM_TITLE_SEED_MAX = 30000
-- <<<<<<<< shade2/item_data.hsp:656 	#define global rangeEgoTitleSp	30000 ..

-- >>>>>>>> shade2/init.hsp:42 	#define global hungerVomit	35000 ...
Const.HUNGER_THRESHOLD_VOMIT = 35000
Const.HUNGER_THRESHOLD_BLOATED = 12000
Const.HUNGER_THRESHOLD_SATISFIED = 10000
Const.HUNGER_THRESHOLD_NORMAL = 5000
Const.HUNGER_THRESHOLD_HUNGRY = 2000
Const.HUNGER_THRESHOLD_STARVING = 1000
-- <<<<<<<< shade2/init.hsp:42 	#define global hungerVomit	35000 ..

-- >>>>>>>> shade2/init.hsp:35 	#define global fatigueHeavy	0 ...
Const.FATIGUE_THRESHOLD_LIGHT = 50
Const.FATIGUE_THRESHOLD_MODERATE = 25
Const.FATIGUE_THRESHOLD_HEAVY = 0
-- <<<<<<<< shade2/init.hsp:37 	#define global fatigueLight	50 ..

-- >>>>>>>> shade2/init.hsp:50 	#define global sleepLight	15 ...
Const.SLEEP_THRESHOLD_LIGHT = 15
Const.SLEEP_THRESHOLD_MODERATE = 30
Const.SLEEP_THRESHOLD_HEAVY = 50
-- <<<<<<<< shade2/init.hsp:52 	#define global sleepHeavy	50 ..

-- >>>>>>>> shade2/init.hsp:80 	#define global maxCorrupt	20000 ...
Const.ETHER_DISEASE_DEATH_THRESHOLD = 20000
-- <<<<<<<< shade2/init.hsp:80 	#define global maxCorrupt	20000 ..

-- >>>>>>>> shade2/init.hsp:109 	#define global defHungerDec	8 ...
Const.HUNGER_DECREMENT_AMOUNT = 8
Const.ALLY_HUNGER_THRESHOLD = 6000
-- <<<<<<<< shade2/init.hsp:111 	#define global defAllyHunger	6000 ..

-- >>>>>>>> shade2/init.hsp:143 	#define global mealValue	15000 ...
Const.INNKEEPER_MEAL_NUTRITION = 15000
-- <<<<<<<< shade2/init.hsp:143 	#define global mealValue	15000 ..

return Const
