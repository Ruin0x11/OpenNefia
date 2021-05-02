local I18N = require("api.I18N")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Gui = require("api.Gui")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Inventory = require("api.Inventory")
local Rand = require("api.Rand")
local ItemMemory = require("mod.elona_sys.api.ItemMemory")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Itemgen = require("mod.elona.api.Itemgen")
local Input = require("api.Input")

local function can_receive_reward()
   local saved_count = save.elona.little_sisters_saved
   local gifts_given = save.elona.strange_scientist_gifts_given

   local required_saved = save.elona.little_sisters_killed
   for i=1,gifts_given+1 do
      required_saved = required_saved + i
   end

   return saved_count >= required_saved
end

local function turn_over_little_sister()
   Gui.mes("talk.unique.strange_scientist.turn_over.text")
   save.elona.little_sisters_saved = save.elona.little_sisters_saved + 1

   Gui.mes_c("talk.unique.strange_scientist.saved_count", "Green",
             save.elona.little_sisters_saved,
             save.elona.little_sisters_killed)
   Chara.find("elona.little_sister", "allies"):vanquish()
   Gui.play_sound("base.complete1")
end

local function can_pick_reward_even_if_unknown(item_id)
   if item_id == "elona.magic_fruit" then
      return Sidequest.is_complete("elona.kamikaze_attack")
   end
   if item_id == "elona.hero_cheese" then
      return Sidequest.is_complete("elona.rare_books")
   end
   if item_id == "elona.happy_apple" then
      return Sidequest.is_complete("elona.pael_and_her_mom")
   end

   return false
end

local function pick_reward()
   -- >>>>>>>> shade2/chat.hsp:2014 				beginTempInv:mode=mode_shop ...
   local is_known = function(i, proto)
      if proto._id == "elona.secret_treasure" then
         return false
      end

      if ItemMemory.is_known(proto._id) then
         return true
      end

      if can_pick_reward_even_if_unknown(proto._id) then
         return true
      end

      return false
   end

   local day = save.base.date.day

   local gen_filter = {
      level = Chara.player():calc("level") * 3 / 2,
      ownerless = true
   }
   local function gen_item(i, item_proto)
      local seed = day + i - 1
      Rand.set_seed(seed)

      gen_filter.id = item_proto._id
      gen_filter.quality = Calc.calc_object_quality(Enum.Quality.Good)
      return Itemgen.create(nil, nil, gen_filter)
   end

   local function is_great_quality_or_better(item)
      return item and item.quality >= Enum.Quality.Great
   end

   local function put_in_inv(inv, item)
      inv:take_object(item)
      return inv
   end

   local inv = data["base.item"]:iter():enumerate()
      :filter(is_known)
      :map(gen_item)
      :filter(is_great_quality_or_better)
      :foldl(put_in_inv, Inventory:new(math.huge))

   Item.create("elona.suitcase", nil, nil, {}, inv)
   Item.create("elona.wallet", nil, nil, {}, inv)

   Rand.set_seed()

   local player = Chara.player()
   Input.query_inventory(player, "elona.inv_take_strange_scientist", { container = inv }, nil)
   -- <<<<<<<< shade2/chat.hsp:2033 				exitTempInv:mode=mode_main ..
end

data:add {
   _type = "elona_sys.dialog",
   _id = "strange_scientist",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.little_sister")
         if flag == 0 then
            return "first"
         elseif flag > 0 then
            return "dialog"
         end

         return "elona_sys.ignores_you:__start"
      end,

      first = {
         text = "talk.unique.strange_scientist.first",
         choices = {
            {"__END__", "ui.more"},
         },
         on_finish = function()
            local player = Chara.player()
            local map = player:current_map()

            Item.create("elona.little_ball", player.x, player.y, {}, map)

            Gui.mes("common.something_is_put_on_the_ground")
            Sidequest.update_journal()
            Sidequest.set_progress("elona.little_sister", 1)
         end
      },

      dialog = {
         text = "talk.unique.strange_scientist.dialog",
         choices = function()
            local choices = {
               {"reward_check", "talk.unique.strange_scientist.choices.reward"},
               {"replenish", "talk.unique.strange_scientist.choices.replenish"}
            }

            if Chara.find("elona.little_sister", "allies") ~= nil then
               table.insert(choices, {"turn_over", "talk.unique.strange_scientist.choices.turn_over"})
            end
            table.insert(choices, {"__END__", "ui.bye"})

            return choices
         end
      },

      reward_check = function()
         if can_receive_reward() then
            return "reward_pick"
         end

         return "reward_not_enough"
      end,
      reward_pick = {
         text = {
            "talk.unique.strange_scientist.reward.dialog",
            pick_reward,
            "talk.unique.strange_scientist.reward.find",
         },
      },
      reward_not_enough = {
         text = "talk.unique.strange_scientist.reward.not_enough",
      },

      replenish = {
         text = "talk.unique.strange_scientist.replenish",
         on_finish = function()
            local player = Chara.player()
            local map = player:current_map()
            Item.create("elona.little_ball", player.x, player.y, {}, map)
            Gui.mes("common.something_is_put_on_the_ground")
         end
      },

      turn_over = {
         on_start = turn_over_little_sister,
         text = "talk.unique.strange_scientist.turn_over.dialog",
         choices = {
            {"__END__", "ui.more"},
         }
      },
   }
}
