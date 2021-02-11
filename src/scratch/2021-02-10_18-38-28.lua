local CodeGenerator = require("api.CodeGenerator")

do
   local config = require("mod.elona.locale.en.config").config

   print(inspect(config))

   local menu = config.menu

   local gen = CodeGenerator:new {
      always_tabify = true
   }

   local ORDER = {
      "game",
      "screen",
      "net",
      "anime",
      "input",
      "keybindings",
      "message",
      "language"
   }

   for _, menu_id in ipairs(ORDER) do
      local items = config.menu[menu_id]
      if type(items) == "table" then
         local menu = {
            _type = "base.config_menu",
            _id = menu_id,

            items = {}
         }

         local out = {}

         for item_id, t in pairs(items) do
            if type(t) == "table" then
               local option = {
                  _id = item_id,

                  type = ""
               }


               out[#out+1] = option

               table.insert(menu.items, "base." .. item_id)
            end
         end

         gen:write_comment("")
         gen:write_comment("Menu: " .. menu_id)
         gen:write_comment("")
         gen:tabify()

         gen:write("data:add_multi(\"base.config_option\", ")
         gen:write_table(out)
         gen:write(")")
         gen:tabify()
         gen:tabify()

         gen:write("data:add ")
         gen:write_table(menu)
         gen:tabify()
         gen:tabify()
      end
   end

   print(gen)
end

for _, lang in ipairs({"en", "jp"}) do
   local config = require("mod.elona.locale." .. lang .. ".config").config
   local out = { config = { menu = {}, option = {} } }

   local ORDER = {
      "game",
      "screen",
      "net",
      "anime",
      "input",
      "keybindings",
      "message",
      "language"
   }

   local gen = CodeGenerator:new {
      always_tabify = true,
      strict = false
   }

   for _, menu_id in ipairs(ORDER) do
      local items = config.menu[menu_id]
      if type(items) == "table" then
         local t = {
            name = items.name
         }
         gen:write_key(menu_id)
         gen:write(" = ")
         gen:write_value(t)
         gen:write(",")
         gen:tabify()
      end
   end

   gen:tabify()
   gen:tabify()

   for _, menu_id in ipairs(ORDER) do
      local items = config.menu[menu_id]
      if type(items) == "table" then
         gen:tabify()
         gen:write_comment("")
         gen:write_comment("Menu: " .. menu_id)
         gen:write_comment("")

         for item_id, t in pairs(items) do
            if type(t) == "table" then
               gen:tabify()

               gen:write_key(item_id)
               gen:write(" = ")
               gen:write_value(t)
               gen:write(",")
               gen:tabify()
            end
         end
      end
   end

   gen:write_table(out)
   print(gen)
end

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
