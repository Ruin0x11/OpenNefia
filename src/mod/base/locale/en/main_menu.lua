return {
  main_menu = {
    about = {
      credits = "Credits",
      foobar_changelog = "Elona foobar Changelog",
      foobar_homepage = "Elona foobar Homepage",
      license = "License",
      title = "About",
      vanilla_homepage = "Vanilla Elona Homepage"
    },
    about_changelog = {
      title = "Changelogs"
    },
    continue = {
      delete = function(_1)
  return ("Do you really want to delete %s ?")
  :format(_1)
end,
      delete2 = function(_1)
  return ("Are you sure you really want to delete %s ?")
  :format(_1)
end,
      hint = {
         action = {
            delete = "Delete"
         }
      },
      no_save = "No save files found",
      title = "Game Selection",
      which_save = "Which save game do you want to continue?"
    },
    incarnate = {
      no_gene = "No gene files found",
      title = "Gene Selection",
      which_gene = "Which gene do you want to incarnate?"
    },
    mod_develop = {
      exist = function(_1)
  return ("Mod '%s' already exists.")
  :format(_1)
end,
      invalid_id = function(_1)
  return ("'%s' is invalid. Only letters, digits, and underscore are allowed.")
  :format(_1)
end,
      key_hint = "Enter [Create]",
      lets_create = "Let's create a mod.",
      no_template = "No template found",
      title = "Mods"
    },
    mod_list = {
      download = {
        failed = "Could not download mod list."
      },
      hint = {
        download = "[Switch To Download]",
        info = "[Mod Info]",
        installed = "[Switch To Installed]",
        toggle = "[Enable/Disable]"
      },
      info = {
        author = "Author",
        description = "Description",
        id = "ID",
        name = "Name",
        title = "Information",
        version = "Version"
      },
      no_readme = "(No README available.)",
      title = {
        download = "Download Mods",
        installed = "Installed Mods"
      }
    },
    mods = {
      menu = {
        develop = "Develop",
        list = "List"
      },
      title = "MOD"
    },
    title_menu = {
      about = "About",
      restore = "Restore an Adventurer",
      exit = "Exit",
      incarnate = "Incarnate an Adventurer",
      mods = "Mods",
      generate = "Generate an Adventurer",
      options = "Options"
    }
  }
}
