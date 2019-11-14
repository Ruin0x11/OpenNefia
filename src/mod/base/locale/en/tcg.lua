return {
  tcg = {
    action = {
      block = "UP: Block.",
      declare_attack = "UP: Declare an attack.",
      no_action_available = "There is no action available.",
      put = "UP: Put the card.",
      sacrifice = "Down: Sacrifice the card.",
      surrender = "Surrender",
      use_skill = "ENTER: Use the skill."
    },
    card = {
      creature = "Creature",
      domain = "Domain",
      land = "Land",
      race = "Race",
      rare = "Rare",
      skill = "Skill",
      spell = "Spell"
    },
    card_not_available = "The card isn't available in this version.",
    deck = {
      choices = {
        edit = "Edit Deck",
        set_as_main = "Set as Main Deck"
      },
      color = {
        black = "Black",
        blue = "Blue",
        red = "Red",
        silver = "Silver",
        white = "White"
      },
      name = function(_1)
  return ("%s Deck")
  :format(_1)
end,
      new = "New"
    },
    domain = {
      jure = "Jure",
      kumiromi = "Kumiromi",
      lulwy = "Lulwy",
      mani = "etc",
      yacatect = "Yacatect"
    },
    end_main_phase = "End your main phase.",
    menu = {
      deck = "Deck",
      just_exit = "Just Exit",
      list = "List",
      save_and_exit = "Save & Exit"
    },
    no_blocker = "No blocker.",
    put = {
      field_full = "Your field is full.",
      not_enough_mana = "You don't have enough mana."
    },
    ref = {
      choose_one_card = "Player chooses and receives 1 card from his deck.",
      draws_two_cards = "Player draws 2 cards.",
      return_creature = "Return target creature to its owner's hand."
    },
    sacrifice = {
      opponent = "The opponent sacrifices the card.",
      you = "You sacrifice the card."
    },
    select = {
      hint = " [Change Filter]  Enter [Select]  Cancel [Exit]"
    }
  }
}