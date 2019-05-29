local chara_make = {}

local menus = {
   "SelectRaceMenu",
   "select_sex",
   "select_class",
   "roll_attributes",
   "select_feats",
   "select_alias",
   "customize_appearance",
   "summary"
}

local cache = setmetatable({}, { __mode = "v" })

function chara_make.query()
   local index = 1
   local menu = menus[index]
   cache[menu] = on_enter_menu(menu)

   local going = true
   while going do
      local result = Input.query(cache[menu])

      if result == "Next" then
         index = index + 1
         menu = menus[index]
         cache[menu] = on_enter_menu(menus[menu])
      elseif result == "Previous" then
         cache[menu] = nil
         index = index - 1

         if index == 0 then
            going = false
         end
      end

      Draw.set_root(cache[menu])
   end

   return false
end

local function on_enter_menu(name)
   local menu, err = pcall(require("api.gui.menu.chara_make." .. name))

   if err or menu == nil then
      error("Cannot find menu " .. name)
   end

   menu = menu:new()
   on_init_menu(menu)

   return menu
end

local function on_init_menu(menu)
   menu:relayout()
end

return chara_make
