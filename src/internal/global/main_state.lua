return {
   frame_start = false,

   --- for determining when low power mode should become enabled
   ---
   --- as this is tightly coupled with the main loop it has to be here instead
   --- of a module
   is_main_title_reached = false,

   stop_low_power = false,

   --- global draw stats provided by love.graphics.getStats.
   ---
   --- These have to be captured right before the final frame is rendered to the
   --- window, and the only practical place to do this is in the main loop, so
   --- this was made a global.
   draw_stats = {}
}
