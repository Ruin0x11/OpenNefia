local GeneEngineering = {}
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Gui = require("api.Gui")
local Chara = require("api.Chara")
local ChooseAllyMenu = require("api.gui.menu.ChooseAllyMenu")
local Input = require("api.Input")
local Anim = require("mod.elona_sys.api.Anim")
local I18N = require("api.I18N")
local Save = require("api.Save")
local CharacterInfoMenu = require("api.gui.menu.CharacterInfoMenu")

-- TODO data_ext
local NON_DONATABLE_BODY_PARTS = table.set {
   "elona.ammo",
   "elona.ranged",
   "elona.body",
}

local function can_donate_body_parts(donor)
   if donor:has_tag("man") then
      return false
   end

   if donor.splits or donor.splits2 then
      return false
   end

   return true
end

function GeneEngineering.calc_donated_body_part(target, donor)
   -- >>>>>>>> shade2/action.hsp:2228 *gene_body ...
   if not can_donate_body_parts(donor) then
      return nil
   end

   -- NOTE: Unlike vanilla, there is no check for free body part slots, since
   -- there is no longer a hard body part limit per character.

   -- Exclude some parts like ammo/ranged (they come on all characters)
   local filter = function(part)
      return not NON_DONATABLE_BODY_PARTS[part.body_part._id]
   end
   local parts = donor:iter_all_body_parts(true):filter(filter):to_list()

   Rand.set_seed(donor.uid)
   Rand.shuffle(parts)

   -- If the target does not have a body part, then always donate it
   local does_not_have_part = function(part)
      return target:body_part_count(part.body_part._id) == 0
   end

   local body_part = fun.iter(parts):filter(does_not_have_part):nth(1)
   if body_part then
      Rand.set_seed()
      return {
         _id = body_part.body_part._id,
         slot = body_part.slot
      }
   end

   -- Find a part whose total number on the donor is greater than the number on
   -- the target, and donate that.
   local fold = function(acc, part)
      acc[part.body_part._id] = (acc[part.body_part._id] or 0) + 1
      return acc
   end
   local counts = fun.iter(parts):foldl(fold, {})

   local body_part_ids = table.keys(counts)
   Rand.shuffle(body_part_ids)

   local found_id = nil
   for _, body_part_id in ipairs(body_part_ids) do
      local count = counts[body_part_ids]
      if count and count < target:body_part_count(body_part_id) then
         found_id = body_part_id
         break
      end
   end

   Rand.set_seed()

   if not found_id then
      return nil
   end

   body_part = assert(fun.iter(parts):filter(function(p) return p.body_part._id == found_id end):nth(1))

   return {
      _id = found_id,
      slot = body_part.slot
   }
   -- <<<<<<<< shade2/action.hsp:2272 	if f=falseM:return rtval(1):else:return falseM ..
end

local function can_donate_skills(donor)
   return not (donor.splits or donor.splits2)
end

function GeneEngineering.calc_donated_skills(target, donor)
   -- >>>>>>>> shade2/action.hsp:2208 *gene_skill ...
   if not can_donate_skills(donor) then
      return {}
   end

   -- Find skills not on the target that are on the donor.
   -- NOTE: This counts temporary skill levels, as with vanilla (sdata instead
   -- of sORG)
   local filter = function(skill)
      return not target:has_skill(skill._id) and donor:has_skill(skill._id)
   end

   local skills = Skill.iter_normal_skills()
      :filter(filter)
      :to_list()

   if #skills == 0 then
      return {}
   end

   Rand.set_seed(donor.uid)
   Rand.shuffle(skills)

   local result = { skills[1] }

   if Rand.one_in(3) then
      local filter = function(s) return s._id ~= skills[1]._id end
      result[#result+1] = fun.iter(skills):filter(filter):nth(1)
   end

   local to_entry = function(s)
      return { _id = s._id, level = 1 }
   end

   Rand.set_seed()

   return fun.iter(result):map(to_entry):to_list()
   -- <<<<<<<< shade2/action.hsp:2226 	return dbMax ..
end

function GeneEngineering.calc_gained_levels(target, donor)
   -- >>>>>>>> shade2/action.hsp:2142 	if cLevel(tc)>cLevel(rc){ ...
   if donor.level <= target.level then
      return 0
   end

   return math.floor((donor.level - target.level) / 2) + 1
   -- <<<<<<<< shade2/action.hsp:2143 		lv=(cLevel(tc)-cLevel(rc))/2+1 ..
end

function GeneEngineering.calc_gained_stat_experience(target, donor, level_diff)
   -- >>>>>>>> shade2/action.hsp:2149 		listMax=0 ...
   if level_diff <= 0 then
      return {}
   end

   local stats = {}

   local org_level = function(stat)
      return { _id = stat._id, level = donor:base_skill_level(stat._id) }
   end
   local sort = function(a, b)
      return a.level > b.level
   end
   local highest_donor_stats = Skill.iter_base_attributes()
      :map(org_level)
      :into_sorted(sort)
      :take(3)
      :to_list()

   for _, entry in ipairs(highest_donor_stats) do
      local target_level = target:base_skill_level(entry._id)
      if entry.level > target_level then
         -- The target character can gain at most 5 levels for each stat.
         local experience = (entry.level - target_level) * 500
         experience = math.clamp(experience * 10 / math.clamp(level_diff, 2, 10), 1000, 10000)

         stats[#stats+1] = {
            _id = entry._id,
            experience = experience
         }
      end
   end

   return stats
   -- <<<<<<<< shade2/action.hsp:2161 		loop ..
end

function GeneEngineering.do_gene_engineer(target, donor)
   local body_part = GeneEngineering.calc_donated_body_part(target, donor)
   if body_part then
      local body_part_name = I18N.localize("base.body_part", body_part._id, "name")
      Gui.mes_c("action.use.gene_machine.gains.body_part", "Green", target, body_part_name)
      target:add_body_part(body_part._id)
   end

   local skills = GeneEngineering.calc_donated_skills(target, donor)
   for _, skill in ipairs(skills) do
      Skill.gain_skill(target, skill._id, skill.level)
      local skill_name = I18N.localize("base.skill", skill._id, "name")
      Gui.mes_c("action.use.gene_machine.gains.ability", "Green", target, skill_name)
   end

   local levels = GeneEngineering.calc_gained_levels(target, donor)
   local stats = GeneEngineering.calc_gained_stat_experience(target, donor, levels)

   if levels > 0 then
      for _ = 1, levels do
         Skill.gain_level(target, false)
      end
      Gui.mes_c("action.use.gene_machine.gains.level", "Green", target, target.level)
   end

   if stats then
      for _, entry in ipairs(stats) do
         Skill.gain_fixed_skill_exp(target, entry._id, entry.experience)
      end
   end

   donor:vanquish()
end

function GeneEngineering.can_gene_engineer(chara, target)
   return chara:skill_level("elona.gene_engineer") + 5 >= target.level
end

function GeneEngineering.use_gene_machine(chara, item)
   local COLOR_INVALID = {160, 10, 10}
   local topic_list_colorizer = function(self, c)
      if not GeneEngineering.can_gene_engineer(chara, c) then
         return COLOR_INVALID
      end
   end

   local topic_on_select = function(self, c)
      if not GeneEngineering.can_gene_engineer(chara, c) then
         Gui.play_sound("base.fail1")
         Gui.mes("ui.ally_list.gene_engineer.skill_too_low")
         return false
      end
      return true
   end

   local target, donor
   local filter = function(ally) return Chara.is_alive(ally) and ally ~= target end

   do
      Gui.mes_newline()
      Gui.mes("action.use.gene_machine.choose_original")

      local topic = {
         window_title = "ui.ally_list.gene_engineer.title",
         x_offset = 0,
         list_colorizer = topic_list_colorizer,
         on_select = topic_on_select
      }

      local allies = chara:iter_other_party_members():filter(filter):to_list()
      Gui.mes("ui.ally_list.gene_engineer.prompt")
      local result, canceled = ChooseAllyMenu:new(allies, topic):query()
      if canceled then
         return false
      end
      target = result.chara
   end

   do
      Gui.mes_newline()
      Gui.mes("action.use.gene_machine.choose_subject")

      local topic = {
         window_title = "ui.ally_list.gene_engineer.title",
         header_status = "ui.ally_list.gene_engineer.body_skill",
         x_offset = 0,
         list_colorizer = topic_list_colorizer,
         on_select = topic_on_select
      }

      topic.info_formatter = function(c)
         -- >>>>>>>> shade2/command.hsp:563 		if allyCtrl=5 :if rc!0{ ...
         local body_part = GeneEngineering.calc_donated_body_part(target, c)
         local skills = GeneEngineering.calc_donated_skills(target, c)

         local body_part_name
         if body_part then
            body_part_name = I18N.localize("base.body_part", body_part._id, "name")
         else
            body_part_name = I18N.get("ui.ally_list.gene_engineer.none")
         end

         local skill_names
         if #skills > 0 then
            local localize = function(s) return I18N.localize("base.skill", s._id, "name") end
            local names = fun.iter(skills):map(localize):to_list()
            skill_names = table.concat(names, ", ")
         else
            skill_names = I18N.get("ui.ally_list.gene_engineer.none")
         end

         return ("%s/%s"):format(body_part_name, skill_names)
         -- <<<<<<<< shade2/command.hsp:566 			} ..
      end

      local allies = chara:iter_other_party_members():filter(filter):to_list()
      Gui.mes("ui.ally_list.gene_engineer.prompt")
      local result, canceled = ChooseAllyMenu:new(allies, topic):query()
      if canceled then
         return false
      end
      donor = result.chara
   end

   Gui.mes_newline()
   Gui.mes("action.use.gene_machine.prompt", target, donor)
   if not Input.yes_no() then
      return false
   end

   Gui.mes_newline()
   Gui.mes_c("action.use.gene_machine.has_inherited", "Yellow", target, donor)

   local cb = Anim.gene_engineering(target.x, target.y)
   Gui.start_draw_callback(cb)

   GeneEngineering.do_gene_engineer(target, donor)

   Save.queue_autosave()
   Skill.gain_skill_exp(chara, "elona.gene_engineer", 1200)

   CharacterInfoMenu:new(target, "ally_status"):query()

   return true
end

return GeneEngineering
