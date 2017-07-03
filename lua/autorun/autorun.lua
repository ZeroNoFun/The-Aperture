
-- client includes
AddCSLuaFile("aperture/main.lua")
AddCSLuaFile("aperture/mapmaker.lua")

-- shared includes
include("aperture/main.lua")
include("aperture/mapmaker.lua")


if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop( "862644776" ) // Workshop download
end

