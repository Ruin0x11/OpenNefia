local MockObject = class("MockObject")

function MockObject:init(rest)
   table.merge(self, rest)
end

function MockObject:build()
end

return MockObject
