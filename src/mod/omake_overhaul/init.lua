local Chara = require("api.Chara")
local Advice = require("api.Advice")
local Skill = require("mod.elona_sys.api.Skill")
local Event = require("api.Event")

data:add_multi(
   "base.config_option",
   {
      { _id = "extra_ally_skill_exp_gain", type = "boolean", default = false },
   }
)

local function init()
   if config.omake_overhaul.extra_ally_skill_exp_gain then
      -- >>>>>>>> oomSEST/src/southtyris.hsp:101701 #deffunc skillexp2 int __bbb, int __ccc, int __ddd ..
      local function gain_skill_exp_in_party(orig_fn, chara, skill, base_exp, exp_divisor_stat, exp_divisor_level)
         local results = {orig_fn(chara, skill, base_exp, exp_divisor_stat, exp_divisor_level)}
         local skill_data = data["base.skill"]:ensure(skill)
         if base_exp > 0 and skill_data.type == "skill" and exp_divisor_level < 1000 and chara:is_ally() then
            for _, ally in Chara.iter_allies(chara:current_map()) do
               if Chara.is_alive(ally) and ally ~= chara then
                  local amount = base_exp / (20 - math.sqrt(math.clamp(ally:skill_level("elona.stat_learning"), 1, 225)))
                  if amount > 0 then
                     orig_fn(ally, skill, amount, exp_divisor_stat, exp_divisor_level)
                  end
               end
            end
         end
         return table.unpack(results)
      end

      Advice.add("around", Skill.gain_skill_exp,
                 "In omake overhaul, allies can also gain extra skill experience when an ally gains skill experience based on Learning.",
                 gain_skill_exp_in_party)
      -- <<<<<<<< oomSEST/src/southtyris.hsp:101723 	return p(86) ..
   end
end
Event.register("base.on_game_initialize", "init", init)
