local Csv = require("mod.extlibs.api.Csv")
local Compat = require("mod.elona_sys.api.Compat")
local CodeGenerator = require("api.CodeGenerator")

print(inspect(data["base.skill"]:ensure("elona.spell_cure_of_jure")))
assert(Compat.convert_122_id("base.skill", 403))

local IDS = {
	actThrowPotionMinor = -9999,
	actThrowPotionMajor = -9998,
	actThrowPotionGreater = -9997,
	actThrowSalt = -9996,
    actMelee = -1,
    actRange = -2,
    actWaitMelee = -3,
    actRandomMove = -4,
	spHealLight = 400,
	spHealCritical= 401,
	spHeal= 402,
	spHealAll= 403,
	spHealRain= 404,
	spHealTouch= 405,
	spRemoveHex= 406,
	spVanishHex= 407,
	spTeleportSelf= 408,
	spTeleportOther= 409,
	spShortTeleport= 410,
	spIdentify= 411,
	spUncurse= 412,
	spRevealArtifact= 413,
	spMagicArrow= 414,
	spNetherArrow= 415,
	spNerveArrow= 416,
	spChaosArrow= 417,
	spDarknessArrow= 418,
	spIceBolt= 419,
	spFireBolt= 420,
	spLightningBolt= 421,
	spDarknessBolt= 422,
	spMindBolt= 423,
	spSummon= 424,
	spSummonWild= 425,
	spSummonFire= 426,
	spSummonPawn= 427,
	spReturn= 428,
	spMagicMap= 429,
	spObjectMap= 430,
	spIceBall= 431,
	spFireBall= 432,
	spChaosBall= 433,
	spSoundBall= 434,
	spCharm= 435,
	spWeb= 436,
	spMist= 437,
	spMakeWall= 438,
	spRestoreBody= 439,
	spRestoreSpirit= 440,
	spWish= 441,
	spHolyShield= 442,
	spDaze= 443,
	spRegeneration= 444,
	spResEle= 445,
	spSpeedUp= 446,
	spSpeedDown= 447,
	spHero= 448,
	spWeakArmor= 449,
	spWeakEle= 450,
	spHolyVeil= 451,
	spNightmare= 452,
	spKnowledge= 453,
	spMutation= 454,
	spAcidGround= 455,
	spFireWall= 456,
	spMakeDoor= 457,
	spIncognito= 458,
	spMagicLaser= 459,
	spMagicBall= 460,
	spResurrect= 461,
	spContingency= 462,
	spPocket= 463,
	spHarvest= 464,
	spMeteor= 465,
	spGravity= 466,

	actDrainBlood=601,
	actBreathFire=602,
	actBreathCold=603,
	actBreathLightning=604,
	actBreathDarkness=605,
	actBreathChaos=606,
	actBreathSound=607,
	actBreathNether=608,
	actBreathNerve=609,
	actBreathPoison=610,
	actBreathMind=611,
	actBreath=612,
	actTouchWeaken=613,
	actTouchHunger=614,
	actTouchPoison=615,
	actTouchNerve=616,
	actTouchFear=617,
	actTouchSleep=618,
	actTeleportTarget=619,
	actDraw=620,
	actRestoreMP=621,
	actPunish=622,
	actHealJure=623,
	actAbsorbMana=624,
	actGodWind=625,
	actKnowSelf=626,
	actShortTeleport=627,
	actChangeCreature=628,
	actAbsorbCharge=629,
	actPutCharge=630,
	actAttackAll=631,
	actMutation=632,
	actGazeEther=633,
	actEtherGround=634,
	actSteal=635,
	actGazeInsane=636,
	actMassHealInsane=637,
	actGazeDim=638,
	actSummonCat=639,
	actSummonYeek=640,
	actSummonPawn=641,
	actSummonFire=642,
	actSummonSister=643,
	actSuicide=644,
	actCurse=645,
	actDeath=646,
	actBoost=647,
	actInsult=648,
	actAttackDist4=649,
	actAttackDist7=650,
	actEatFood=651,
	actGazeMana=652,
	actVanish=653,
	actPregnant=654,
	actGrenade=655,
	actLeaderShip=656,
	actEhekatl=657,
	actFinish=658,
	actDropMine=659,
	actDisassemble=660,
}

local ACTIONS = {
   [-9999] = { id = "elona.throw_potion", id_set = CodeGenerator.gen_literal [[Filters.isetthrowpotionminor]] },
   [-9998] = { id = "elona.throw_potion", id_set = CodeGenerator.gen_literal [[Filters.isetthrowpotionmajor]] },
   [-9997] = { id = "elona.throw_potion", id_set = CodeGenerator.gen_literal [[Filters.isetthrowpotiongreater]] },
   [-9996] = { id = "elona.throw_potion", item   = "elona.salt" },
   [-1] = { id = "elona.melee" },
   [-2] = { id = "elona.ranged" },
   [-3] = { id = "elona.wait_melee" },
   [-4] = { id = "elona.random_move" },
}

local map = function(row)
   local _id = Compat.convert_122_id("base.chara", tonumber(row.id))
   local skills = {}
   local ai_actions = {}

   local function add_skills(ty, name)
      for _, skill_name in ipairs(string.split(row[name], " ")) do
         if skill_name == "" then
            break
         end
         local elona_id = assert(IDS[skill_name], skill_name)

         ai_actions[ty] = ai_actions[ty] or {}

         if elona_id < 0 then
            table.insert(ai_actions[ty], ACTIONS[elona_id])
         else
            local skill_id = assert(Compat.convert_122_id("base.skill", elona_id))
            skills[#skills+1] = skill_id
            local id
            if elona_id >=400 and elona_id < 500 then
               id = "elona.magic"
            else
               id = "elona.action"
            end
            table.insert(ai_actions[ty], { id = id, skill_id = skill_id })
         end
      end
   end

   if row.actHeal ~= "" then
      local elona_id = assert(IDS[row.actHeal], row.actHeal)
      assert(elona_id >= 400 and elona_id < 500)
      local skill_id = assert(Compat.convert_122_id("base.skill", elona_id))
      skills[#skills+1] = skill_id
      ai_actions.low_health_action = { id = "elona.magic", skill_id = skill_id }
   end

   add_skills("main", "actMain")
   add_skills("sub", "actSub")

   if row.aiSub ~= "" then
      ai_actions.sub_action_chance = tonumber(row.aiSub)
   end

   if row.aiCalm ~= "" then
      ai_actions.calm_action = "calm_" .. row.aiCalm:sub(3):lower()
   end

   local ai_distance
   if row.aiDistance ~= "" then
      ai_distance = tonumber(row.aiDistance)
   end

   local ai_move_chance
   if row.aiMoveFreq ~= "" then
      ai_move_chance = tonumber(row.aiMoveFreq)
   end

   return {
      _id = _id,

      skills = next(skills) and skills,
      ai_actions = next(ai_actions) and ai_actions,
      ai_distance = ai_distance,
      ai_move_chance = ai_move_chance
   }
end

for _, row in Csv.parse_file("../../study/elona122/shade2/db/creature.csv", {header=true, shift_jis=true})
   :map(map)
   :filter(function(i) return table.count(i) > 1 end)
do
   local gen = CodeGenerator:new()
   gen:write_table(row)
   print(gen)
end

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
