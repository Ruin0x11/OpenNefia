return {
  building = {
    built_new = function(_1)
  return ("You've built a %s!")
  :format(_1)
end,
    built_new_house = "You've built a new house!",
    can_only_use_in_world_map = "You can only use it in the world map.",
    cannot_build_anymore = "You can't build a building anymore.",
    cannot_build_it_here = "You can't build it here.",
    home = {
      design = {
        help = "Left click to place the tile, right click to pick the tile under your mouse cursor, movement keys to move current position, hit the enter key to show the list of tiles, hit the cancel key to exit."
      },
      move = {
        dont_touch_me = function(_1)
  return ("%s\"Don't touch me!\"")
  :format(basename(_1))
end,
        invalid = "The location is invalid.",
        is_moved = function(_1)
  return ("%s %s moved to the location.")
  :format(basename(_1), is(_1))
end,
        where = function(_1)
  return ("Where do you want to move %s?")
  :format(basename(_1))
end,
        who = "Move who?"
      },
      rank = {
        change = function(_1, _2, _3, _4, _5)
  return ("Furniture Value:%s Heirloom Value:%s Home Rank:%s->%s Your home is now known as <%s>.")
  :format(_1, _2, _3, _4, _5)
end,
        enter_key = "Enter key,",
        heirloom_rank = "Heirloom Rank",
        place = function(_1)
  return ("%s")
  :format(_1)
end,
        star = "*",
        title = "Home Value",
        type = {
          base = "Base",
          deco = "Deco",
          heir = "Heir",
          total = "Total"
        },
        value = "Value"
      },
      staying = {
        add = {
          ally = function(_1)
  return ("%s stay%s at your home now.")
  :format(basename(_1), s(_1))
end,
          worker = function(_1)
  return ("%s take%s charge of the job now.")
  :format(basename(_1), s(_1))
end
        },
        count = function(_1, _2)
  return ("%s members are staying at your home (Max: %s).")
  :format(_1, _2)
end,
        remove = {
          ally = function(_1)
  return ("%s %s no longer staying at your home.")
  :format(basename(_1), is(_1))
end,
          worker = function(_1)
  return ("You remove %s from %s job.")
  :format(basename(_1), his(_1))
end
        }
      }
    },
    house_board = {
      choices = {
        allies_in_your_home = "Allies in your home",
        assign_a_breeder = "Assign a breeder",
        assign_a_shopkeeper = "Assign a shopkeeper",
        design = "Design",
        extend = function(_1)
  return ("Extend(%s GP)")
  :format(_1)
end,
        home_rank = "Home rank",
        move_a_stayer = "Move a stayer",
        recruit_a_servant = "Recruit a servant"
      },
      item_count = function(_1, _2, _3, _4)
  return ("There are %s items and %s furniture in %s.(Max:%s) ")
  :format(_2, _3, _1, _4)
end,
      only_use_in_home = "You can only use it in your home.",
      what_do = "What do you want to do?"
    },
    museum = {
      rank_change = function(_1, _2, _3)
  return ("Museum Rank:%s->%s Your museum is now known as <%s>.")
  :format(_1, _2, _3)
end
    },
    names = {
      _521 = "museum",
      _522 = "shop",
      _542 = "crop",
      _543 = "storage",
      _572 = "ranch",
      _712 = "dungeon"
    },
    ranch = {
      current_breeder = function(_1)
  return ("Current breeder is %s.")
  :format(basename(_1))
end,
      no_assigned_breeder = "You haven't assigned a breeder yet."
    },
    really_build_it_here = "Really build it here? ",
    shop = {
      current_shopkeeper = function(_1)
  return ("Current shopkeeper is %s.")
  :format(basename(_1))
end,
      extend = function(_1)
  return ("You extend your shop! You can display max of %s items now!")
  :format(_1)
end,
      info = "Shop",
      log = {
        and_items = function(_1)
  return (" and %s items")
  :format(_1)
end,
        could_not_sell = function(_1, _2)
  return ("%s customers visited your shop but %s couldn't sell any item.")
  :format(_1, basename(_2))
end,
        gold = function(_1)
  return ("%s gold pieces")
  :format(_1)
end,
        no_shopkeeper = "Your shop doesn't have a shopkeeper.",
        sold_items = function(_1, _2, _3, _4)
  return ("%s customers visited your shop and %s sold %s items. %s put %s in the shop strong box.")
  :format(_1, basename(_2), _3, basename(_2), _4)
end
      },
      no_assigned_shopkeeper = "You haven't assigned a shopkeeper yet."
    }
  }
}
