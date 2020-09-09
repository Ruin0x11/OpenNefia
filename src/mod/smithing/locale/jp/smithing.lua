return {
   smithing = {
      inventory_proto = {
         forge = "鍛える",
      },
      blacksmith_hammer = {
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
                  equip_melee_short_sword = "短剣",
                  equip_melee_lance = "槍",
                  equip_melee_halberd = "鉾槍",
                  equip_melee_hand_axe = "斧",
                  equip_melee_axe = "大斧",
                  equip_melee_scythe = "鎌",

                  equip_body_mail = "鎧",
                  equip_head_helm = "兜",
                  equip_shield_shield = "盾",
                  equip_leg_heavy_boots = "重靴",
                  equip_wrist_gauntlet = "ガントレット"
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

         repair_furniture = {
            prompt = "何を素材にする？",
            finished = function(item)
               return ("%sの加工を終えた。"):format(itemname(item))
            end
         },

         repair_equipment = {
            no_repairs_are_necessary = "鍛冶の必要はない。",
            finished = {
               repair = function(item)
                  return ("%sの修理を終えた。"):format(itemname(item))
               end,
               upgrade = function(item)
                  return ("%sを打ち直した。"):format(itemname(item))
               end
            }
         },

         upgrade_hammer = {
            is_not_upgradeable = "鍛冶の必要はない。",
            finished = function(hammer)
               return ("%sは転生した。"):format(itemname(hammer))
            end,
         },

         skill_increases = "あなたは鍛冶の技術の向上を感じた。"
      }
   }
}
