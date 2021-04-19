local IAspect = require("api.IAspect")
local IItemLocalizableExtra = require("mod.elona.api.aspect.IItemLocalizableExtra")
local IItemThrowable = require("mod.elona.api.aspect.IItemThrowable")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local IItemInittable = require("mod.elona.api.aspect.IItemInittable")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local Chara = require("api.Chara")
local Anim = require("mod.elona_sys.api.Anim")
local Enum = require("api.Enum")
local Rand = require("api.Rand")

local IItemMonsterBall = class.interface("IItemMonsterBall",
                                  {
                                     chara_id = { type = "string", optional = true },
                                     chara_level = { type = "string", optional = true },
                                     max_level = "number"
                                  },
                                  {
                                     IAspect,
                                     IItemInittable,
                                     IItemThrowable,
                                     IItemUseable,
                                     IItemLocalizableExtra,
                                  })


IItemMonsterBall.default_impl = "mod.elona.api.aspect.ItemMonsterBallAspect"

function IItemMonsterBall:localize_action()
   return "base:aspect._.elona.IItemMonsterBall.action_name"
end

function IItemMonsterBall:on_init_params(item, init_params)
   if self.max_level <= 0 then
      self.max_level = Rand.rnd((init_params.level or 0) + 1) + 1
   end
   item.value = 2000 + self.max_level * self.max_level + self.max_level * 100
end

function IItemMonsterBall:on_thrown(item, params)
   -- >>>>>>>> shade2/action.hsp:17 	if iId(ci)=idMonsterBall{ ...
   local map = params.chara:current_map()
   local clone = item:clone()
   if map and map:can_take_object(clone) then
      assert(map:take_object(clone, params.x, params.y))
      clone.amount = 1
   end
   -- <<<<<<<< shade2/action.hsp:21 		} ..

   -- >>>>>>>> shade2/action.hsp:27 		snd seThrow2 ...
   local aspect = clone:get_aspect(IItemMonsterBall)
   Gui.play_sound("base.throw2", params.x, params.y)
   map:refresh_tile(params.x, params.y)
   local target = Chara.at(params.x, params.y, map)
   if target then
      Gui.mes("action.throw.hits", target)

      -- >>>>>>>> shade2/action.hsp:32 			if iId(ci)=idMonsterBall{ ...
      if not aspect:can_capture_chara(clone, target) then
         return true
      end

      Gui.mes_c("action.throw.monster_ball.capture", "Green", target)
      local anim = Anim.load("elona.anim_smoke", params.x, params.y)
      Gui.start_draw_callback(anim)

      aspect:capture_chara(clone, target)
      -- <<<<<<<< shade2/action.hsp:43 				 ..
   end
   -- <<<<<<<< shade2/action.hsp:31 			txtMore:txt lang(name(tc)+"に見事に命中した！","It hits  ..

   return true
end

function IItemMonsterBall:can_capture_chara(item, target)
   if config.base.development_mode then
      return true
   end

   if target:is_ally() or target:has_any_roles() or target:calc("quality") == Enum.Quality.Unique or target:calc("is_precious") then
      Gui.mes("action.throw.monster_ball.cannot_be_captured")
      return false
   end

   if target:calc("level") > self:calc(item, "max_level") then
      Gui.mes("action.throw.monster_ball.not_enough_power")
      return false
   end

   if target.hp > target:calc("max_hp") / 10 then
      Gui.mes("action.throw.monster_ball.not_weak_enough")
      return false
   end

   return true
end

function IItemMonsterBall:capture_chara(item, target)
   self.chara_id = target._id
   self.chara_level = target.level
   item.weight = math.clamp(target.weight, 10000, 100000)
   item.value = 1000
   item.can_throw = false

   -- >>>>>>>> shade2/action.hsp:49 			chara_vanquish tc ...
   -- triggers "elona_sys.on_quest_check" via "base.on_chara_vanquished", so
   -- the capture counts for quest hunting targets
   target:vanquish()
   -- <<<<<<<< shade2/action.hsp:50 			check_quest ..
end

function IItemMonsterBall:on_use(item, params)
   -- >>>>>>>> shade2/action.hsp:2082 	case effMonsterBall ...
   local source = params.chara

   local chara_id = self:calc(item, "chara_id")
   if chara_id == nil then
      Gui.mes("action.use.monster_ball.empty")
      return "player_turn_query"
   end

   if not source:can_recruit_allies() then
      Gui.mes("action.use.monster_ball.party_is_full")
      return "player_turn_query"
   end

   Gui.mes("action.use.monster_ball.use", item:build_name(1))
   item.amount = item.amount - 1
   item:refresh_cell_on_map()

   -- TODO void
   local chara = self:spawn_chara(item, chara_id, source.x, source.y, source:current_map())
   if chara then
      source:recruit_as_ally(chara)
   end
   -- <<<<<<<< shade2/action.hsp:2089 	swbreak ..
end

function IItemMonsterBall:spawn_chara(item, chara_id, x, y, map)
   return Chara.create(chara_id, x, y, {}, map)
end

function IItemMonsterBall:localize_extra(item)
   local chara_id = self:calc(item, "chara_id")

   if chara_id then
      local chara_name = I18N.localize("base.chara", chara_id, "name")
      return ("(%s)"):format(chara_name)
   end

   return I18N.get("base:aspect._.elona.IItemMonsterBall.level", self:calc(item, "max_level"))
end

return IItemMonsterBall
