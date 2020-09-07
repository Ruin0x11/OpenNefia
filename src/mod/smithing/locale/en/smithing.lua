return {
   smithing = {
      inventory_proto = {
         forge = "Forge"
      },
      blacksmith_hammer = {
         is_not_upgradeable = "This hammer has not \"reached\".",
         no_repairs_are_necessary = "No repairs are necessary.",
         requires_anvil = "Requires an anvil.",
         requires_anvil_and_furnace = "Requires a furnace and an anvil.",
         sound = { "*clank*", "*clang*" },

         create = {
            prompt = "What will you create?",

            item_types = {
               -- IDs of `base.item_type`
               elona = {
                  equip_melee_broadsword = "Claymore",
                  equip_melee_long_sword = "Long sword",
                  equip_melee_dagger = "Dagger",
                  equip_melee_lance = "Spear",
                  equip_melee_halberd = "Halberd",
                  equip_melee_hand_axe = "Axe",
                  equip_melee_axe = "Bardish",
                  equip_melee_scythe = "Scythe",
               }
            },

            failed = "Failed to create an item...",
            superior = "You created a superior equipment!",
            masterpiece = "You created a masterpiece!",
            success = function(item_name)
               return ("You successfully create %s!"):format(item_name)
            end,

            prompt_name_artifact = "What do you want to name this artifact?"
         },

         upgrade_hammer = function(hammer)
            return ("Upgrade of %s was finished."):format(itemname(hammer))
         end,

         skill_increases = "Your Smithing skill increases."
      }
   }
}
