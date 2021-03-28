data:add {
   _type = "base.keybind",
   _id = "toggle_autoplant",

   -- In oom, you used to be able to autoplant by holding Ctrl and moving, but
   -- in OpenNefia any key pressed with a modifier counts as a different key for
   -- purposes of keybinds. It seems that HSP ignores modifiers when checking
   -- arrow key presses.
   default = "P"
}
