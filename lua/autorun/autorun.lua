AddCSLuaFile( "aperture/main.lua" )
AddCSLuaFile( "autorun/cl_GASLControlPanel.lua" )

include( "aperture/main.lua" )

if SERVER then
	AddCSLuaFile()
	--resource.AddWorkshop( "" ) // Workshop download
end
