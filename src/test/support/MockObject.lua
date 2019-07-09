local MockObject = class.class("MockObject")

function MockObject:init(rest)
   table.merge(self, rest)
end

function MockObject:pre_build()
end

function MockObject:normal_build()
end

function MockObject:build()
end

return MockObject
