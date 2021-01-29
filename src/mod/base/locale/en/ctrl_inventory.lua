return {
  ui = {
    inv = {
      buy = {
        how_many = function(_1)
  return ("How many? (1 to %s)")
  :format(_1)
end,
        not_enough_money = { "You check your wallet and shake your head.", "You need to earn more money!" },
        prompt = function(_1, _2)
  return ("Do you really want to buy %s for %s gold pieces?")
  :format(_1, _2)
end,
        window = {
          price = "Price"
        }
      },
      cannot_use_cargo_items = "You can only use cargo items on the surface.",
      common = {
        does_not_exist = "The item doesn't exist.",
        invalid = function(_1, _2)
  return ("Invalid Item Id found. Item No:%s, Id:%s has been removed from your inventory.")
  :format(_1, _2)
end,
        inventory_is_full = "Your inventory is full.",
        set_as_no_drop = "It's set as no-drop. You can reset it from the <examine> menu.",
        shortcut = {
          cargo = "You can't make a shortcut for cargo stuff."
        }
      },
      drop = {
        cannot_anymore = "You can't drop items any more.",
        how_many = function(_1)
  return ("How many? (1 to %s)")
  :format(_1)
end,
        multi = "You can continuously drop items."
      },
      eat = {
        too_bloated = { "Your are too full to eat.", "You are too bloated to eat any more.", "Your stomach can't digest any more." }
      },
      equip = {
        blessed = "You feel as someone is watching you intently.",
        cursed = "You suddenly feel a chill and shudder.",
        doomed = "You are now one step closer to doom.",
        too_heavy = "It's too heavy to equip.",
        you_equip = function(_1)
  return ("You equip %s.")
  :format(itemname(_1))
end
      },
      examine = {
        no_drop = {
          set = function(_1)
  return ("You set %s as no-drop.")
  :format(itemname(_1))
end,
          unset = function(_1)
  return ("%s is no longer set as no-drop.")
  :format(itemname(_1))
end
        }
      },
      give = {
        abortion = "Abortion...",
        cursed = "It's cursed!",
        engagement = function(_1)
  return ("%s blushes.")
  :format(name(_1))
end,
        inventory_is_full = function(_1)
  return ("%s inventory is full.")
  :format(his(_1))
end,
        is_sleeping = function(_1)
  return ("%s %s sleeping.")
  :format(name(_1), is(_1))
end,
        love_potion = {
          dialog = { "You scum!", "What are you trying to do!", "Guard! Guard! Guard!" },
          text = function(_1)
  return ("%s throws it on the ground angrily.")
  :format(name(_1))
end
        },
        no_more_drink = "Enough for me.",
        present = {
          dialog = "Thank you!",
          text = function(_1, _2)
  return ("You give %s %s.")
  :format(name(_1), itemname(_2, 1))
end
        },
        refuse_dialog = {
          _0 = "Too heavy!",
          _1 = "No way.",
          _2 = "I don't want it.",
          _3 = "Never!"
        },
        refuses = function(_1, _2)
  return ("%s refuse%s to take %s.")
  :format(name(_1), s(_1), itemname(_2, 1))
end,
        too_creepy = "I don't want it. It's too creepy.",
        you_hand = function(_1, _2)
  return ("You hand %s to %s.")
  :format(itemname(_1, 1), name(_2))
end
      },
      identify = {
        fully = function(_1)
  return ("The item is fully identified as %s.")
  :format(itemname(_1))
end,
        need_more_power = "You need higher identification to gain new knowledge.",
        partially = function(_1)
  return ("The item is half-identified as %s.")
  :format(itemname(_1))
end
      },
      offer = {
        no_altar = "There's no altar here."
      },
      put = {
        container = {
          cannot_hold_cargo = "The container cannot hold cargos",
          full = "The container is full.",
          too_heavy = function(_1)
  return ("The container can only hold items weight less than %s.")
  :format(_1)
end
        },
        guild = {
          have_no_quota = "You have no quota for Mages Guild.",
          remaining = function(_1)
  return ("%sguild points are needed to gain a rank.")
  :format(_1)
end,
          you_deliver = function(_1)
  return ("You deliver %s. ")
  :format(itemname(_1))
end,
          you_fulfill = "You fulfill the quota!"
        },
        harvest = function(_1, _2, _3, _4)
  return ("You deliver %s. +%s Delivered(%s) Quota (%s)")
  :format(itemname(_1), _2, _3, _4)
end,
        tax = {
          do_not_have_to = "You don't have to pay your tax yet.",
          not_enough_money = "You don't have enough money.",
          you_pay = function(_1)
  return ("You pay %s.")
  :format(itemname(_1))
end
        }
      },
      sell = {
        how_many = function(_1)
  return ("How many? (1 to %s)")
  :format(_1)
end,
        not_enough_money = function(_1)
  return ("%s checks %s wallet and shake %s head.")
  :format(name(_1), his(_1), his(_1))
end,
        prompt = function(_1, _2)
  return ("Do you really want to sell %s for %s gold pieces?")
  :format(_1, _2)
end
      },
      steal = {
        do_not_rob_ally = "You don't want to rob your ally.",
        has_nothing = function(_1)
  return ("%s has nothing to steal.")
  :format(name(_1))
end,
        there_is_nothing = "There's nothing to steal."
      },
      take = {
        can_claim_more = function(_1)
  return ("You can claim %s more heirloom%s.")
  :format(_1, s(_1))
end,
        no_claim = "You don't have a claim.",
        really_leave = "Really leave these items?"
      },
      take_ally = {
        cursed = function(_1)
  return ("%s is cursed and can't be taken off.")
  :format(itemname(_1))
end,
        refuse_dialog = "It's mine.",
        swallows_ring = function(_1, _2)
  return ("%s swallows %s angrily.")
  :format(name(_1), itemname(_2, 1))
end,
        window = {
          equip = "Equip",
          equip_weight = "EquipWt"
        },
        you_take = function(_1)
  return ("You take %s.")
  :format(_1)
end
      },
      throw = {
        cannot_see = "You can't see the location.",
        location_is_blocked = "The location is blocked."
      },
      title = {
        general = "Examine what? ",
        give = "Which item do you want to give? ",
        buy = "What do you want to buy? ",
        sell = "What do you want to sell? ",
        identify = "Which item do you want to identify? ",
        use = "Use what? ",
        open = "Open what? ",
        cook = "Cook what? ",
        dip_source = "Blend what? ",
        dip = function(_1)
  return ("Which item do you want to apply the effect of %s?")
  :format(_1)
end,
        offer = "What do you want to offer to your God? ",
        drop = "Drop what? ",
        trade = "Which item do you want to trade? ",
        present = function(_1)
  return ("What do you offer for %s?")
  :format(_1)
end,
        take = "Take what? ",
        target = "Target what? ",
        put = "Put what? ",
        receive = "Which item do you want to take? ",
        throw = "Throw what? ",
        steal = "Steal what? ",
        trade2 = "Trade what? ",
        reserve = "Which item do you want to reserve? ",
        get = "Which item do you want to pick up? ",
        equip = "Equip what?",
        eat = "Eat what? ",
        read = "Read what? ",
        drink = "Drink what? ",
        zap = "Zap what? "
      },
      trade = {
        too_low_value = function(_1)
  return ("You don't have stuff that match %s.")
  :format(_1)
end,
        you_receive = function(_1, _2)
  return ("You receive %s in exchange for %s.")
  :format(_2, _1)
end
      },
      trade_medals = {
        inventory_full = "Your inventory is full.",
        medal_value = function(_1)
  return ("%s Coins")
  :format(_1)
end,
        medals = function(_1)
  return ("(Coins: %s)")
  :format(_1)
end,
        not_enough_medals = "You don't have enough coins.",
        window = {
          medal = "Medal"
        },
        you_receive = function(_1)
  return ("You receive %s!")
  :format(itemname(_1, 1))
end
      },
      window = {
        change = "Change",
        ground = "Ground",
        main_hand = "Main hand",
        name = "Name",
        select_item = function(_1)
  return ("%s")
  :format(_1)
end,
        tag = {
          multi_drop = "Multi Drop",
          no_drop = "Tag No-Drop"
        },
        total_weight = function(_1, _2, _3)
  return ("Weight %s/%s  Cargo %s")
  :format(_1, _2, _3)
end,
        weight = "Weight"
      }
    }
  }
}
