return {
   production = {
      menu = {
         detail = "Detail",
         make = function(_1)
            return ("Make [%s]")
               :format(_1)
         end,
         material = "Material",
         product = "Product",
         requirement = "Requirement",
         skill_needed = "Skill needed",
         title = "Production",
         x = "x"
      },
      you_crafted = function(_1)
         return ("You crafted %s.")
            :format(_1)
      end,
      you_do_not_meet_requirements = "You don't meet requirements to create the item."
   }
}
