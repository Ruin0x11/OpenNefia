local CharaGen = require("api.test.gen.CharaGen")
local QuickCheck = require("api.test.QuickCheck")
local IntGen = require("api.test.gen.IntGen")
local Skill = require("mod.elona_sys.api.Skill")
local Test = require("api.test.Test")
local Debug = require("api.Debug")

function test_skill_set_base_level()
   local skill_id = "elona.evasion"

   local function property(chara, level)
      chara:mod_base_skill_level(skill_id, level, "set")
      return Test.assert_eq(level, chara:base_skill_level(skill_id))
   end

   QuickCheck.assert(property, {CharaGen:new(), IntGen:new(1, 1999)})
end

function test_formula_skill_exp_gain_level()
   local skill_id = "elona.evasion"

   local function property(chara, level, exp)
      Debug.hook(chara, "set_base_skill", 0)
      chara:mod_base_skill_level(skill_id, level, "set")
      chara:mod_skill_experience(skill_id, 0, "set")
      Skill.gain_skill_exp(chara, skill_id, exp, 1, 1)
      return Test.assert_eq(level, chara:base_skill_level(skill_id))
   end

   QuickCheck.assert(property, {CharaGen:new(), IntGen:new(1, 1999), IntGen:new(1, 999)})
end

function test_formula_skill_exp_gain()
   local skill_id = "elona.evasion"

   local function property(chara, level, exp)
      chara:mod_base_skill_level(skill_id, level, "set")
      chara:mod_skill_experience(skill_id, 0, "set")
      local prev = chara:skill_experience(skill_id)
      Skill.gain_skill_exp(chara, skill_id, exp, 1, 1)
      return Test.assert_gt(chara:skill_experience(skill_id), prev)
   end

   QuickCheck.assert(property, {CharaGen:new(), IntGen:new(1, 1999), IntGen:new(100, 900)})
end
