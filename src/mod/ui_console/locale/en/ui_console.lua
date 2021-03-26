return {
   ui_console = {
      greeting = "Hello, world!",
      greeting_custom = function(_1)
         return ("Hello, %s!"):format(_1)
      end
   }
}
