local Assert = require("api.test.Assert")
local Activity = require("api.Activity")
local Feat = require("api.Feat")

function test_Activity_create__params_validation()
   Assert.throws_error(function() Activity.create("elona.searching", {feat=42}) end,
      "base.activity 'elona.searching' received invalid value for parameter 'feat': Value is not of type \"map_object<base.feat>\": 42")

   Assert.throws_error(function() Activity.create("elona.searching", {feat=nil}) end,
      "base.activity 'elona.searching' received invalid value for parameter 'feat': Value is not of type \"map_object<base.feat>\": nil")

   local feat = Feat.create("elona.material_spot", nil, nil, {ownerless=true, params={material_spot_info="elona.spring"}})

   Assert.throws_error(function() Activity.create("elona.searching", {feat=feat, dood=42}) end,
      "base.activity 'elona.searching' does not accept parameter 'dood'")

   local activity = Activity.create("elona.searching", {feat=feat})
   Assert.eq(feat, activity.params.feat)
end

function test_Activity_create__params_reserved_property_name()
   local activity = Activity.create("elona.mining", {x=4,y=5})
   Assert.eq(4, activity.params.x)
   Assert.eq(5, activity.params.y)
end
