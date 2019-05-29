local chara_make = {}

local menus = ["select_race",
              "select_sex",
              "select_class",
              "roll_attributes",
              "select_feats",
              "select_alias",
              "customize_appearance",
              "summary"]

function chara_make.query()
   local index = 1
   local menu = on_enter_menu(menus[index])

   local going = true
   while going do
      local result = Input.query(menu)

      if result == "Next" then
         index = index + 1
      end
   end
end

local function on_enter_menu(name)
   local menu
   if name == "select_race" then
   elseif name == "select_race" then
   end

   if menu == nil then
      error("Cannot find menu " .. name)
   end

   on_init_menu(menu)

   return menu
end

local function on_init_menu(name)

   error("Cannot find menu " .. name)
end

return chara_make
