local env = require("internal.env")

local function mock_loadfile(api, val)
   return {
      package = {
         searchpath = function() return api end,
      },
      loadfile = function()
         return function() return val end
      end
   }
end

test("env - hotload", function()
        local api

        ok(t.with_mocks(mock_loadfile("envtest", { value = 1 }),
                        function()
                           api = env.require("envtest")
                        end
        ))

        ok(t.with_mocks(mock_loadfile("envtest", { value = 2 }),
                        function()
                           api = env.require("envtest")
                        end
        ))

        ok(t.are_same(1, api.value))

        ok(t.with_mocks(mock_loadfile("envtest", { value = 2 }),
                        function()
                           api = env.hotload("envtest")
                        end
        ))

        ok(t.are_same(2, api.value))
end)
