local Assert = require("api.test.Assert")
local Feat = require("api.Feat")

function test_Feat_create__params_validation()
   Assert.throws_error(function() Feat.create("elona.material_spot", nil, nil, {ownerless=true, params={material_spot_info=42}}) end,
         "Feat 'elona.material_spot' requires parameter 'material_spot_info' of type string")

   local feat = Feat.create("elona.material_spot", nil, nil, {ownerless=true,params={material_spot_info="elona.spring"}})
   Assert.eq("elona.spring", feat.params.material_spot_info)

   feat = Feat.create("elona.material_spot", nil, nil, {ownerless=true, params={}})
   Assert.eq(nil, feat.params.material_spot_info)

   feat = Feat.create("elona.material_spot", nil, nil, {ownerless=true})
   Assert.eq(nil, feat.params.material_spot_info)
end
