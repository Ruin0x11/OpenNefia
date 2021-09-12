local Assert = require("api.test.Assert")
local Feat = require("api.Feat")

function test_Feat_create__params_validation()
   Assert.throws_error(function() Feat.create("elona.material_spot", nil, nil, {ownerless=true, params={material_spot_info=42}}) end,
      "base.feat 'elona.material_spot' received invalid value for parameter 'material_spot_info': Value is not of type \"data_id<elona.material_spot_feat_info>\": 42")

   Assert.throws_error(function() Feat.create("elona.material_spot", nil, nil, {ownerless=true, params={material_spot_info="elona.sprint", dood=42}}) end,
         "base.feat 'elona.material_spot' does not accept parameter 'dood'")

   Assert.throws_error(function() Feat.create("elona.material_spot", nil, nil, {ownerless=true, params={}}) end,
         "base.feat 'elona.material_spot' is missing required parameter 'material_spot_info': Value is not of type \"data_id<elona.material_spot_feat_info>\": nil")

   Assert.throws_error(function() Feat.create("elona.material_spot", nil, nil, {ownerless=true}) end,
         "base.feat 'elona.material_spot' is missing required parameter 'material_spot_info': Value is not of type \"data_id<elona.material_spot_feat_info>\": nil")

   local feat = Feat.create("elona.material_spot", nil, nil, {ownerless=true,params={material_spot_info="elona.spring"}})
   Assert.eq("elona.spring", feat.params.material_spot_info)
end
