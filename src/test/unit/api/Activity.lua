local Assert = require("api.test.Assert")
local Activity = require("api.Activity")
local Feat = require("api.Feat")

function test_Activity_create__params_validation()
   Assert.throws_error(function() Activity.create("elona.searching", {feat=42}) end,
         "Activity 'elona.searching' requires parameter 'feat' of type table")

   local feat = Feat.create("elona.material_spot", nil, nil, {ownerless=true})
   local activity = Activity.create("elona.searching", {feat=feat})
   Assert.eq(feat, activity.params.feat)

   activity = Activity.create("elona.searching", {feat=nil})
   Assert.eq(nil, activity.params.feat)
end

function test_Activity_create__params_reserved_property_name()
   local activity = Activity.create("elona.mining", {x=4,y=5})
   Assert.eq(4, activity.params.x)
   Assert.eq(5, activity.params.y)
end
