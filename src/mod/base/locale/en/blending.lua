return {
  blending = {
    failed = "The blending attempt failed!",
    ingredient = {
      _1 = "suitable flavoring",
      _2 = "any ore",
      _3 = "something made of wood",
      _4 = "fish",
      _5 = "any item",
      corpse = function(_1)
  return ("%s corpse")
  :format(_1)
end
    },
    prompt = {
      from_the_start = "From the start",
      go_back = "Go back",
      how_many = "How many items do you want to create?",
      start = "Start blending"
    },
    rate_panel = {
      and_hours = function(_1)
  return ("and %s hours")
  :format(_1)
end,
      required_time = function(_1)
  return ("Time: %s")
  :format(_1)
end,
      success_rate = function(_1)
  return ("Success Rate: %s")
  :format(_1)
end,
      turns = function(_1)
  return ("%s turns")
  :format(_1)
end
    },
    recipe = {
      _200 = "love food",
      _201 = "dyeing",
      _202 = "poisoned food",
      _203 = "fireproof coating",
      _204 = "acidproof coating",
      _205 = "bait attachment",
      _206 = "blessed item",
      _207 = "well refill",
      _208 = "natural potion",
      _209 = "2 artifacts fusion",
      _210 = "3 artifacts fusion",
      counter = function(_1)
  return ("%s recipes")
  :format(_1)
end,
      hint = "[Page]  ",
      name = "Name",
      of = function(_1)
  return ("Recipe of %s")
  :format(_1)
end,
      title = "Choose a recipe",
      warning = "(*) The feature is not implemented yet.",
      which = "Which recipe do you want to use?"
    },
    required_material_not_found = "A required material cannot be found.",
    sounds = { "*pug*", "*clank*" },
    started = function(_1, _2)
  return ("%s start%s blending of %s.")
  :format(name(_1), s(_1), _2)
end,
    steps = {
      add_ingredient = function(_1)
  return ("Add \"%s\".")
  :format(_1)
end,
      add_ingredient_prompt = function(_1)
  return ("Add %s")
  :format(_1)
end,
      ground = " (Ground)",
      item_counter = function(_1)
  return ("%s items")
  :format(_1)
end,
      item_name = "Name",
      you_add = function(_1)
  return ("You add %s.")
  :format(itemname(_1))
end
    },
    succeeded = function(_1)
  return ("You successfully create %s!")
  :format(itemname(_1, 1))
end,
    success_rate = {
      almost_impossible = "Almost impossible",
      bad = "Bad",
      goes_down = "The success rate goes down.",
      goes_up = "The success rate goes up.",
      impossible = "Impossible!",
      maybe = "Maybe",
      no_problem = "No problem",
      perfect = "Perfect!",
      piece_of_cake = "Piece of cake!",
      probably_ok = "Probably OK",
      very_bad = "Very bad",
      very_likely = "Very likely"
    },
    window = {
      add = function(_1, _2)
  return ("Add %s(Stock:%s)")
  :format(_1, _2)
end,
      choose_a_recipe = "Choose a recipe",
      chose_the_recipe_of = function(_1)
  return ("Chose the recipe of %s")
  :format(_1)
end,
      havent_identified = "You haven't identified it yet.",
      no_inherited_effects = "No inherited effects",
      procedure = "Blending Procedure",
      required_equipment = "Required equipment:",
      required_skills = "Required Skills:",
      selected = function(_1)
  return ("Selected %s")
  :format(itemname(_1))
end,
      start = "Start blending!",
      the_recipe_of = function(_1)
  return ("The recipe of %s")
  :format(_1)
end
    },
    you_lose = function(_1)
  return ("You lose %s.")
  :format(itemname(_1, 1))
end
  }
}