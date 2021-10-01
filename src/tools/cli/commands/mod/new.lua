local mod_info = require("internal.mod_info")
local fs = require("util.fs")
local ansicolors = require("thirdparty.ansicolors")

return function(args)
   local mod_id = args.mod_id
   local example = args.example

   if not mod_info.is_valid_mod_identifier(mod_id) then
      error("Mod ID must start with a letter and consist of letters, numbers or underscores only")
   end

   local mod_dir = fs.join("mod", mod_id)
   if fs.exists(mod_dir) then
      error(("Path '%s' already exists."):format(mod_id))
   end
   fs.create_directory(mod_dir)

   local function create(path, content)
      path = fs.join(mod_dir, path)
      local parent = fs.parent(path)
      fs.create_directory(parent)
      fs.write(path, content or "")
      print(ansicolors(("    %%{bright}%%{green}create%%{reset}  %s"):format(path)))
   end

   local tmpl_mod_lua = ([[
return {
   id = "%s",
   version = "0.1.0",
   dependencies = {
      elona = ">= 0.1.0"
   }
}
]]):format(mod_id)

   local tmpl_init_lua = ([[
require("mod.%s.data.init")
require("mod.%s.event.init")
]]):format(mod_id, mod_id)

   local tmpl_data_init_lua = ([[
-- Add more data definition files in this directory.

-- require("mod.%s.data.chara")
-- require("mod.%s.data.item")
]]):format(mod_id, mod_id)

   local tmpl_event_init_lua = ([[
-- Add more event definition files in this directory.

require("mod.%s.event.save")
]]):format(mod_id)

   local tmpl_event_save_lua = ([[
-- Initialize save data for a new save game here, or remove this file if it's
-- unnecessary.
local Event = require("api.Event")

local function init_save()
   local s = save.%s
   -- s.high_score = 0
   -- s.my_data = { ... }
end

Event.register("base.on_init_save", "Init save (%s)", init_save)
]]):format(mod_id, mod_id)

   local tmpl_example_api_lua = ([[
local Gui = require("api.Gui")

local ExampleApi = {}

function ExampleApi.do_something(arg)
   -- Your code here.
   if arg then
      Gui.mes("%s.greeting_custom", arg)
   else
      Gui.mes("%s.greeting")
   end
end

return ExampleApi
]]):format(mod_id, mod_id)

   local tmpl_locale_en_lua = ([[
return {
   %s = {
      greeting = "Hello, world!",
      greeting_custom = function(_1)
         return ("Hello, %%s!"):format(_1)
      end
   }
}
]]):format(mod_id)

   local tmpl_locale_jp_lua = ([[
return {
   %s = {
      greeting = "こんにちは、世界!",
      greeting_custom = function(_1)
         return ("こんにちは、%%s!"):format(_1)
      end
   }
}
]]):format(mod_id)

   local tmpl_readme_md = ([[
# %s

Describe your mod here.
]]):format(mod_id)

   create("mod.lua", tmpl_mod_lua)
   create("init.lua", tmpl_init_lua)
   create("data/init.lua", tmpl_data_init_lua)
   create("event/init.lua", tmpl_event_init_lua)
   create("event/save.lua", tmpl_event_save_lua)
   if example then
      create("api/ExampleApi.lua", tmpl_example_api_lua)
      create(("locale/en/%s.lua"):format(mod_id), tmpl_locale_en_lua)
      create(("locale/jp/%s.lua"):format(mod_id), tmpl_locale_jp_lua)
   else
      create("api/.keep")
      create("locale/en/.keep")
      create("locale/jp/.keep")
   end
   create("graphic/.keep")
   create("sound/.keep")
   create("README.md", tmpl_readme_md)

   print(("Created new mod '%s' at %s/."):format(args.mod_id, mod_dir))
end
