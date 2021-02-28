return {
   dialog_ui_ex = {
      greeting = "Hello, world!",
      greeting_custom = function(_1)
         return ("Hello, %s!"):format(_1)
      end
   }
}
