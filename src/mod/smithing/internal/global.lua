local CircularBuffer = require("api.CircularBuffer")

return {
   tracked_hammer = nil,
   sps_intervals = CircularBuffer:new(100, 0),
   previous_sps_time = nil
}
