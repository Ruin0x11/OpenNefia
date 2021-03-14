return {
  map = {
    loading_failed = "Map loading failed.",
    location_changed = function(_1, _2, _3, _4, _5)
  return ("The location of %s has been changed from x%s:y%s to x%s:y%s.")
  :format(_1, _2, _3, _4, _5)
end,
    misc_location = {
      _1 = "Mine",
      _2 = "Crop",
      _3 = "Art Atelier",
      _4 = "Temple",
      _5 = "Smuggler's Hideout",
      _6 = "Light House"
    },
    prompt_initialize = "Initialize this map? (Warning, only do this if an error occurs when loading this map. Make sure make a backup of the current save folder before doing this.)",
    quest = {
      field = "Field nearby town",
      on_enter = {
        conquer = function(_1, _2)
  return ("You have to slay %s within %s minites.")
  :format(_1, _2)
end,
        harvest = function(_1, _2)
  return ("To complete the quest, you have to harvest %s worth farm products and put them into the delivery chest within %s minutes.")
  :format(_1, _2)
end,
        party = function(_1, _2)
  return ("You have to warm up the party within %s minites. Your target score is %s points.")
  :format(_1, _2)
end
      },
      outskirts = "The outskirts",
      party_room = "Party Room",
      urban_area = "Urban area",
      harvest = "Outskirts Fields",
    },
    since_leaving = {
      time_passed = function(_1, _2, _3)
  return ("%s day%s and %s hour%s have passed since you left %s.")
  :format(_1, s(_1), _2, s(_2), _3)
end,
      walked = {
        you = function(_1)
  return ("You've walked about %s miles and have gained experience.")
  :format(_1)
end,
        you_and_allies = function(_1)
  return ("You and your allies have walked about %s miles and have gained experience.")
  :format(_1)
end
      }
    },
    you_see = function(_1)
  return ("You see %s.")
  :format(_1)
end,
    you_see_an_entrance = function(_1, _2)
  return ("You see an entrance leading to %s.(Approximate danger level: %s) ")
  :format(_1, _2)
end,
    default_name = "New Map"
  }
}
