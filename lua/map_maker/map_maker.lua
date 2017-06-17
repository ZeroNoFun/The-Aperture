AddCSLuaFile()

MAP_MAKER = {}
MAP_MAKER.PROPS = {}

function MAP_MAKER:RegisterProp(prop)
table.insert(MAP_MAKER.PROPS, prop)
print(prop.name .. " Registered!")
end