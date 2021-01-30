local CodeGenerator = require("api.CodeGenerator")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Chara = require("api.Chara")
local AliasPrompt = require("api.gui.AliasPrompt")
local Effect = require("mod.elona.api.Effect")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local DeferredEvents = require("mod.elona.api.DeferredEvents")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Event = require("api.Event")
local Enum = require("api.Enum")
local Itemgen = require("mod.tools.api.Itemgen")
local ItemMemory = require("mod.elona_sys.api.ItemMemory")
local Itemname = require("mod.elona.api.Itemname")

data:add_type {
   name = "wish_handler",
   fields = {
      {
         name = "on_wish",
         type = "function(string, IChara)",
         default = CodeGenerator.gen_literal [[
function(wish, chara)
      return false
   end
]],
         template = true,
         doc = [[
Code to run on wish. `wish` contains the wish text. `chara` contains the wishing character.
]]
      },
      {
         name = "ordering",
         default = 0,
         template = true,
         doc = [[
Order to run the handler in. Lower values get checked before later ones.

This is important as the item/skill name matchers can match an arbitrary string,
so more specific handlers should have lower priority than those.
]]
      },
   }
}

local function match_any(wish, locale_key)
   local cands = I18N.get_array(locale_key)
   local match = function(cand) return wish == cand end

   return fun.iter(cands):any(match)
end

local function add_wish_handler(_id, match, on_wish, priority)
   if type(match) == "string" then
      local match_ = match
      match = function(wish, chara)
         return match_any(wish, match_)
      end
   end
   if type(match) == "function" then
      local on_wish_ = on_wish
      on_wish = function(wish, chara)
         if match(wish, chara) then
            on_wish_(wish, chara)
            return true
         end
         return false
      end
   end

   data:add {
      _type = "elona.wish_handler",
      _id = _id,

      on_wish = on_wish,
      priority = priority
   }
end

-- >>>>>>>> shade2/command.hsp:1460 	 ..
local function god_inside(wish)
   Gui.mes("wish.wish_god_inside")
end
add_wish_handler("god_inside", "wish.special_wish.god_inside", god_inside, 10000)

local function man_inside(wish)
   Gui.mes("wish.wish_man_inside")
end
add_wish_handler("man_inside", function(wish) return wish:match(I18N.get("wish.special_wish.man_inside")) end, man_inside, 10000)

-- TODO custom god summoning
local function ehekatl(wish, chara)
   Gui.mes_c(I18N.quote_speech("wish.wish_ehekatl"), "Talk")
   Chara.create("elona.ehekatl", chara.x, chara.y, {}, chara:current_map())
end
add_wish_handler("ehekatl", "wish.special_wish.ehekatl", ehekatl, 10000)

local function lulwy(wish, chara)
   Gui.mes_c(I18N.quote_speech("wish.wish_lulwy"), "Talk")
   Chara.create("elona.lulwy", chara.x, chara.y, {}, chara:current_map())
end
add_wish_handler("lulwy", "wish.special_wish.lulwy", lulwy, 10000)

local function opatos(wish, chara)
   Gui.mes_c(I18N.quote_speech("wish.wish_opatos"), "Talk")
   Chara.create("elona.opatos", chara.x, chara.y, {}, chara:current_map())
end
add_wish_handler("opatos", "wish.special_wish.opatos", opatos, 10000)

local function kumiromi(wish, chara)
   Gui.mes_c(I18N.quote_speech("wish.wish_kumiromi"), "Talk")
   Chara.create("elona.kumiromi", chara.x, chara.y, {}, chara:current_map())
end
add_wish_handler("kumiromi", "wish.special_wish.kumiromi", kumiromi, 10000)

local function mani(wish, chara)
   Gui.mes_c(I18N.quote_speech("wish.wish_mani"), "Talk")
   Chara.create("elona.mani", chara.x, chara.y, {}, chara:current_map())
end
add_wish_handler("mani", "wish.special_wish.mani", mani, 10000)

local function youth(wish, chara)
   Gui.mes("wish.wish_youth")
   chara.age = math.min(chara.age + 20, save.base.date.year - 12)
end
add_wish_handler("youth", "wish.special_wish.youth", youth, 10000)

local function alias(wish, chara)
   if save.base.is_wizard then
      Gui.mes("wish.wish_alias.impossible")
      return
   end

   Gui.mes("wish.wish_alias.what_is_your_new_alias")
   local result, canceled = AliasPrompt:new("character"):query()
   if result then
      Gui.mes("wish.wish_alias.new_alias", result.alias)
      chara.title = result.alias
   else
      Gui.mes("wish.wish_alias.no_change")
   end
end
add_wish_handler("alias", "wish.special_wish.alias", alias, 10000)

local function sex(wish, chara)
   if chara.gender == "male" then
      chara.gender = "female"
   else
      chara.gender = "male"
   end
   Gui.mes("wish.wish_sex", chara, "ui.sex." .. chara.gender)
end
add_wish_handler("sex", "wish.special_wish.sex", sex, 10000)

local function redemption(wish, chara)
   if chara.karma >= 0 then
      Gui.mes("wish.wish_redemption.you_are_not_a_sinner", chara)
      return true
   end
   Effect.modify_karma(chara, -(chara.karma / 2))
   Gui.mes("wish.wish_redemption.what_a_convenient_wish")
end
add_wish_handler("redemption", "wish.special_wish.redemption", redemption, 10000)

local function death(wish, chara)
   Gui.mes("wish.wish_death")
   chara:damage_hp(chara:calc("max_hp") + 1, "elona.unknown")
end
add_wish_handler("death", "wish.special_wish.death", death, 10000)

local function ally(wish, chara)
   DeferredEvent.add(DeferredEvents.first_ally)
end
add_wish_handler("ally", "wish.special_wish.ally", ally, 10000)

local function gold(wish, chara)
   Gui.mes_c("wish.wish_gold", "Yellow")
   local amount = (chara:calc("level") / 3 + 1) * 10000
   Item.create("elona.gold_piece", chara.x, chara.y, { amount = amount }, chara:current_map())
end
add_wish_handler("gold", "wish.special_wish.gold", gold, 10000)

local function small_medal(wish, chara)
   Gui.mes_c("wish.wish_small_medal", "Yellow")
   local amount = 3 + Rand.rnd(3)
   Item.create("elona.small_medal", chara.x, chara.y, { amount = amount }, chara:current_map())
end
add_wish_handler("small_medal", "wish.special_wish.small_medal", small_medal, 10000)

local function platinum(wish, chara)
   Gui.mes_c("wish.wish_platinum", "Yellow")
   local amount = 5
   Item.create("elona.platinum_coin", chara.x, chara.y, { amount = amount }, chara:current_map())
end
add_wish_handler("platinum", "wish.special_wish.platinum", platinum, 10000)
-- <<<<<<<< shade2/command.hsp:1545 		} ..

local function normalize_input(wish)
   -- >>>>>>>> shade2/command.hsp:1386 *wish_fix ..
   if I18N.language() == "jp" then
      wish = wish:gsub("[ \t,]", "")
   end

   wish = wish:gsub(I18N.get("wish.general_wish.item"), "")
   wish = wish:gsub(I18N.get("wish.general_wish.skill"), "")
   -- <<<<<<<< shade2/command.hsp:1401 	return ..
   -- >>>>>>>> shade2/module.hsp:2063 	cnv_str s,"card ","" ..
   wish = wish:gsub(I18N.get("wish.general_wish.card"), "")
   wish = wish:gsub(I18N.get("wish.general_wish.figure"), "")
   -- >>>>>>>> shade2/module.hsp:2063 	cnv_str s,"card ","" ..

   wish = string.strip_whitespace(wish)
   wish = wish:lower()

   return wish
end

local function fuzzy_match(wish, str)
   str = str:lower()
   local priority = 0
   if wish == str then
      priority = 10000
   end
   if wish == "" then
      return 0
   end
   for pos, _ in utf8.codes(str) do
      if str:sub(pos):match(wish) then
         priority = priority + 50 * (pos + 1) + Rand.rnd(15)
      end
   end
   return priority
end

local function is_wishable_skill(skill_entry)
   return skill_entry.type ~= "resistance" and skill_entry.type ~= "stat_special"
end

-- >>>>>>>> shade2/command.hsp:1616 *wish_skill ..
local function skill(wish, chara)
   wish = normalize_input(wish)

   local found
   local max_priority = 0
   for _, skill_entry in data["base.skill"]:iter():filter(is_wishable_skill) do
      local skill_name = I18N.get("ability." .. skill_entry._id .. ".name")
      local priority = fuzzy_match(wish, skill_name)
      if priority > max_priority then
         max_priority = priority
         found = skill_entry
      end
   end

   if found then
      local skill_name = I18N.get("ability." .. found._id .. ".name")
      if chara:has_base_skill(found._id) then
         Gui.mes_c("wish.your_skill_improves", "Yellow", skill_name)
         Skill.gain_fixed_skill_exp(chara, found._id, 1000)
         Skill.modify_potential(chara, found._id, 25)
      else
         Gui.mes_c("wish.you_learn_skill", "Yellow", skill_name)
         Skill.gain_skill(chara, found._id, 1)
      end
      return true
   end
end
-- <<<<<<<< shade2/command.hsp:1656 	goto *com_wish_end ..
add_wish_handler("skill", nil, skill, 100000)

local function is_wishable_item(item_entry)
   return item_entry.is_wishable
end

-- >>>>>>>> shade2/command.hsp:1557 *wish_item ..
local function item(wish, chara)
   wish = normalize_input(wish)

   local found = {}
   for _, item_entry in data["base.item"]:iter():filter(is_wishable_item) do
      -- need to make sure the name is "scroll of ally" instead of "ally"
      local item_name = Itemname.qualify_name(item_entry._id)
      local priority = fuzzy_match(wish, item_name)
      if priority > 0 then
         found[#found+1] = { item_entry = item_entry, priority = priority }
      end
   end

   local max_by = function(a, b) if a.priority > b.priority then return a else return b end end

   while #found > 0 do
      local entry = fun.iter(found):max_by(max_by)
      local item_entry = entry.item_entry
      local filter = {
         id = item_entry._id,
         level = chara:calc("level") + 10,
         quality = Enum.Quality.Great,
      }

      if item_entry.before_wish then
         filter = item_entry.before_wish(filter, chara) or filter
      end

      filter.no_stack = true
      filter.no_oracle = true

      local created = Itemgen.create(chara.x, chara.y, filter, chara:current_map())

      local consider = true
      if created:calc("is_precious") or created.quality == Enum.Quality.Unique then
         if not (save.base.is_wizard or config.base.development_mode) then
            consider = false
         end
      end

      if consider then
         created:emit("elona.on_item_created_from_wish", {chara=chara})
         Effect.identify_item(created, Enum.IdentifyState.Full)
         Gui.mes("wish.something_appears", created)
         return true
      else
         ItemMemory.forget_generated(created._id)
         created:remove()
         table.iremove_value(found, entry)
      end
   end

   return false
end
-- <<<<<<<< shade2/command.hsp:1614 		} ..
add_wish_handler("item", nil, item, 200000)

local function extract_chara_id(wish)
   -- >>>>>>>> shade2/command.hsp:1683 *wish_monster ..
   wish = normalize_input(wish)

   local found
   local max_priority = 0
   for _, chara_entry in data["base.chara"]:iter() do
      local chara_name = I18N.get("chara." .. chara_entry._id .. ".name")
      local priority = fuzzy_match(wish, chara_name)
      print(priority, wish, chara_name)
      if priority > 0 then
         priority = 1000 - (chara_name:len() - wish:len()) * 10
         if priority > max_priority then
            max_priority = priority
            found = chara_entry._id
         end
      end
   end

   return found or "elona.at"
   -- <<<<<<<< shade2/command.hsp:1701 	return ..
end

local function adjust_potion_scroll_amount(item)
   if item:has_category("elona.drink") or item:has_category("elona.potion") then
      item.amount = 3 + Rand.rnd(2)
      if item.value >= 5000 then
         item.amount = 3
      end
      if item.value >= 10000 then
         item.amount = 2
      end
      if item.value >= 20000 then
         item.amount = 1
      end
   end
end

Event.register("elona.on_item_created_from_wish", "Adjust potion/scroll amount", adjust_potion_scroll_amount)

local function card(wish, chara)
   local chara_id = extract_chara_id(wish)
   local card = Item.create("elona.card", chara.x, chara.y, {}, chara:current_map())
   card.params.chara_id = chara_id
   Gui.mes("wish.something_appears_from_nowhere", card)
   return true
end

local function figure(wish, chara)
   local chara_id = extract_chara_id(wish)
   local figure = Item.create("elona.figurine", chara.x, chara.y, {}, chara:current_map())
   figure.params.chara_id = chara_id
   Gui.mes("wish.something_appears_from_nowhere", figure)
   return true
end

-- >>>>>>>> shade2/command.hsp:1550 	if (instr(inputLog,0,lang("スキル","skill"))!-1):got ..
local function common(wish, chara)
   if wish:match(I18N.get("wish.general_wish.skill")) then
      return skill(wish, chara)
   elseif wish:match(I18N.get("wish.general_wish.item")) then
      return item(wish, chara)
   elseif wish:match(I18N.get("wish.general_wish.card")) then
      return card(wish, chara)
   elseif wish:match(I18N.get("wish.general_wish.figure")) then
      return figure(wish, chara)
   end

   return false
end
-- <<<<<<<< shade2/command.hsp:1553 	if (instr(inputLog,0,lang("剥製","figure"))!-1)or(i ..
add_wish_handler("common", nil, common, 50000)
