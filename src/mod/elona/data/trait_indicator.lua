local I18N = require("api.I18N")

data:add {
   _type = "base.trait_indicator",
   _id = "incognito",

   ordering = 100000,

   -- >>>>>>>> shade2/command.hsp:746 	traitExtra cIncognito,	lang("あなたは変装している","You are ...
   applies_to = function(chara)
      return chara:calc("is_anorexic")
   end,

   make_indicator = function(chara)
      return {
         desc = I18N.get("trait.incognito")
      }
   end
   -- <<<<<<<< shade2/command.hsp:746 	traitExtra cIncognito,	lang("あなたは変装している","You are ..
}

data:add {
   _type = "base.trait_indicator",
   _id = "pregnant",

   ordering = 110000,

   -- >>>>>>>> shade2/command.hsp:747 	traitExtra cPregnant,	lang("あなたは寄生されている","You are ...
   applies_to = function(chara)
      return chara:calc("is_pregnant")
   end,

   make_indicator = function(chara)
      return {
         desc = I18N.get("trait.pregnant")
      }
   end
   -- <<<<<<<< shade2/command.hsp:747 	traitExtra cPregnant,	lang("あなたは寄生されている","You are ..
}

data:add {
   _type = "base.trait_indicator",
   _id = "anorexia",

   ordering = 120000,

   -- >>>>>>>> shade2/command.hsp:748 	traitExtra cAnorexia,	lang("あなたは拒食症だ","You have a ...
   applies_to = function(chara)
      return chara:calc("is_anorexic")
   end,

   make_indicator = function(chara)
      return {
         desc = I18N.get("trait.anorexia")
      }
   end
   -- <<<<<<<< shade2/command.hsp:748 	traitExtra cAnorexia,	lang("あなたは拒食症だ","You have a ..
}

data:add {
   _type = "base.trait_indicator",
   _id = "body_is_complicated",

   ordering = 130000,

   -- >>>>>>>> shade2/command.hsp:751 	if cBodySpdFix(tc)!0{ ...
   applies_to = function(chara)
      -- TODO gene engineer
      return false
   end,

   make_indicator = function(chara)
      -- TODO gene engineer
      local speed_fix = 0
      return {
         desc = I18N.get("trait.body_is_complicated", speed_fix)
      }
   end
   -- <<<<<<<< shade2/command.hsp:753 		} ..
}

data:add {
   _type = "base.trait_indicator",
   _id = "ether_disease_speed",

   ordering = 140000,

   -- >>>>>>>> shade2/command.hsp:746 	traitExtra cIncognito,	lang("あなたは変装している","You are ...
   applies_to = function(chara)
      return chara:calc("ether_disease_speed") ~= 0
   end,

   make_indicator = function(chara)
      local desc
      if chara:calc("ether_disease_speed") > 0 then
         desc = I18N.get("trait.ether_disease_grows.fast")
      else
         desc = I18N.get("trait.ether_disease_grows.slow")
      end
      return {
         desc = desc
      }
   end
   -- <<<<<<<< shade2/command.hsp:746 	traitExtra cIncognito,	lang("あなたは変装している","You are ..
}
