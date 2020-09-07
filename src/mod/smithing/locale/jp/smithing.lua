return {
   smithing = {
      inventory_proto = {
         forge = "鍛える",
      },
      blacksmith_hammer = {
         is_not_upgradeable = "鍛冶の必要はない。",
         no_repairs_are_necessary = "鍛冶の必要はない。",
         requires_anvil = "金床が必要だ。",
         requires_anvil_and_furnace = "溶鉱炉と金床が必要だ。",
         sound = { " *カキーン* ", " *カーン* " },

         create = {
            prompt = "何を作る？",

            item_types = {
               -- IDs of `base.item_type`
               elona = {
                  equip_melee_broadsword = "大剣",
                  equip_melee_long_sword = "長剣",
                  equip_melee_dagger = "短剣",
                  equip_melee_lance = "槍",
                  equip_melee_halberd = "鉾槍",
                  equip_melee_hand_axe = "斧",
                  equip_melee_axe = "大斧",
                  equip_melee_scythe = "鎌",
               }
            },

            failed = "作成に失敗した……",
            superior = "これは自信作だ！",
            masterpiece = "これは会心の出来だ！",
            success = function(item_name)
               return ("%sの作成に成功した！"):format(item_name)
            end,

            prompt_name_artifact = "銘は？"
         },

         upgrade_hammer = function(hammer)
            return ("%sは転生した。"):format(itemname(hammer))
         end,

         skill_increases = "あなたは鍛冶の技術の向上を感じた。"
      }
   }
}
