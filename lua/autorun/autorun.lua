AddCSLuaFile( "aperture/main.lua" )
AddCSLuaFile( "autorun/cl_gaslcontrolpanel.lua" )

include( "aperture/main.lua" )

if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop( "862644776" ) // Workshop download
end
