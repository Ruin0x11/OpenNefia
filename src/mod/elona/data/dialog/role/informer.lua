local StayingCharas = require("api.StayingCharas")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local ChooseAllyMenu = require("api.gui.menu.ChooseAllyMenu")
local CharacterInfoMenu = require("api.gui.menu.CharacterInfoMenu")
local ListAdventurersMenu = require("mod.elona.api.gui.ListAdventurersMenu")
local Calc = require("mod.elona.api.Calc")
local Adventurer = require("mod.elona.api.Adventurer")

local function informer_cost(player, ally)
   local cost = Calc.calc_informer_investigate_cost(player, ally)
   return math.max(math.floor(cost), 0)
end

data:add {
   _type = "elona_sys.dialog",
   _id = "informer",

   nodes = {
      list_adventurers = function(t)
         local map = assert(t.speaker:current_map())
         local advs = Adventurer.iter_all(map):to_list()
         ListAdventurersMenu:new(advs):query()
         return "list_adventurers_done"
      end,
      list_adventurers_done = {
         text = "talk.npc.informer.show_adventurers" ,
         jump_to = "elona.default:__start"
      },

      investigate_ally = function(t)
         Gui.mes("ui.ally_list.gene_engineer.prompt")

         local map = assert(t.speaker:current_map())
         local allies = StayingCharas.iter_allies_and_stayers(map):filter(Chara.is_alive):to_list()

         local result = ChooseAllyMenu:new(allies):query()
         if not result then
            return "elona.default:you_kidding"
         end

         return { node_id = "investigate_ally_confirm", params = { ally = result.chara } }
      end,
      investigate_ally_confirm = {
         text = "talk.npc.informer.investigate_ally.cost",
         choices = function(t, state, params)
            local player = Chara.player()
            local choices = {}
            if player.gold >= informer_cost(player, params.ally) then
               choices[#choices+1] = {"investigate_ally_show", "talk.npc.informer.investigate_ally.choices.pay", params = params}
            end
            choices[#choices+1] = {"elona.default:you_kidding", "talk.npc.informer.investigate_ally.choices.go_back"}
            return choices
         end
      },
      investigate_ally_show = function(t, state, params)
         local player = Chara.player()
         Gui.play_sound("base.paygold1")
         player.gold = player.gold - informer_cost(player, params.ally)
         Gui.refresh_hud()
         Gui.play_sound("base.pop2")
         CharacterInfoMenu:new(params.ally, "chara_status"):query()
         return "elona.default:__start"
      end,
   }
}
