return {
  wish = {
    general_wish = {
      card = "card",
      figure = "figure",
      item = "item",
      skill = "skill",
      summon = "summon"
    },
    it_is_sold_out = "It's sold out.",
    something_appears = function(_1)
  return ("%s appear%s.")
  :format(itemname(_1), s(_1))
end,
    something_appears_from_nowhere = function(_1)
  return ("%s appear%s from nowhere.")
  :format(itemname(_1), s(_1))
end,
    special_wish = {
      alias = { "aka", "title", "name", "alias" },
      ally = { "friend", "company", "ally" },
      death = "death",
      fame = "fame",
      god_inside = "god inside",
      gold = { "money", "gold", "wealth", "fortune" },
      man_inside = "man inside",
      platinum = { "platina", "platinum" },
      redemption = { "redemption", "atonement" },
      sex = "sex",
      small_medal = { "coin", "medal", "small coin", "small medal" },
      youth = { "youth", "age", "beauty" }
    },
    what_do_you_wish_for = "What do you wish for? ",
    wish_alias = {
      impossible = "*laugh*",
      new_alias = function(_1)
  return ("You will be known as <%s>.")
  :format(_1)
end,
      no_change = "What a waste of a wish!",
      what_is_your_new_alias = "What's your new alias?"
    },
    wish_death = "If you wish so...",
    wish_man_inside = "There's no man inside.",
    wish_gold = "Lots of gold pieces appear.",
    wish_god_inside = "There's no God inside.",
    wish_platinum = "Platinum pieces appear.",
    wish_redemption = {
      what_a_convenient_wish = "What a convenient wish!",
      you_are_not_a_sinner = "You aren't a sinner."
    },
    wish_sex = function(_1, _2)
  return ("%s become %s!")
  :format(name(_1), _2)
end,
    wish_small_medal = "A small coin appears.",
    wish_youth = "A typical wish.",
    you_learn_skill = function(_1)
  return ("You learn %s!")
  :format(_1)
end,
    your_skill_improves = function(_1)
  return ("Your %s skill improves!")
  :format(_1)
end,
    your_wish = function(_1)
  return ("%s!!")
  :format(_1)
end
  }
}
