AddCSLuaFile( "aperture/main.lua" )
AddCSLuaFile( "autorun/cl_gaslcontrolpanel.lua" )

include( "aperture/main.lua" )

if SERVER then
	AddCSLuaFile()
	--resource.AddWorkshop( "" ) // Workshop download
end
